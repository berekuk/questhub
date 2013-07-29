package Play::DB::Stencils;

=head1 SYNOPSIS

    $stencils->add({ name => "read a book", realm => "chaos" });

=cut

use 5.010;
use utf8;

use Moo;
with 'Play::DB::Role::Common';

use Play::Mongo;
use Play::DB qw(db);
use MongoDB::OID;

use Type::Params qw( compile );
use Types::Standard qw( Undef Dict Str Optional Bool ArrayRef );
use Play::Types qw( Id Login Realm StencilPoints );

sub _prepare {
    my $self = shift;
    my ($stencil) = @_;
    $stencil->{ts} = $stencil->{_id}->get_time;
    $stencil->{_id} = $stencil->{_id}->to_string;
    $stencil->{points} ||= 1;

    return $stencil;
}

sub _fill_quests {
    my $self = shift;
    my ($stencil) = @_;

    # FIXME - this can get expensive
    my $quests = db->quests->list({ stencil => $stencil->{_id} });
    $stencil->{quests} = $quests;
    $stencil->{stat} = {};
    for my $quest (@$quests) {
        $stencil->{stat}{$quest->{status}}++;
    }
    return;
}

sub add {
    my $self = shift;
    state $check = compile(Dict[
        realm => Realm,
        name => Str,
        description => Optional[Str],
        author => Login,
        points => Optional[StencilPoints],
    ]);
    my ($params) = $check->(@_);
    $params->{points} ||= 1;

    die "$params->{author} is not a keeper of $params->{realm}" unless db->realms->is_keeper($params->{realm}, $params->{author});

    my $id = $self->collection->insert($params, { safe => 1 });

    my $stencil = { %$params, _id => $id };
    $self->_prepare($stencil);

    db->events->add({
        type => 'add-stencil',
        author => $params->{author},
        stencil_id => $id->to_string,
        realm => $params->{realm},
    });

    db->realms->inc_stencils($params->{realm});

    return $stencil;
}

sub edit {
    my $self = shift;
    state $check = compile(Id, Dict[
        user => Login,
        name => Optional[Str],
        description => Optional[Str],
        points => Optional[StencilPoints],
    ]);
    my ($id, $params) = $check->(@_);
    my $user = delete $params->{user};

    # explicitly specifying that we don't want any quest info - just in case stencils->get defaults change in the future
    my $stencil = $self->get($id, { quests => 0 });

    delete $stencil->{_id};
    delete $stencil->{ts};
    die "got stencil->{quests}" if $stencil->{quests}; # extra precaution

    my $realm = $stencil->{realm};
    unless (db->realms->is_keeper($stencil->{realm}, $user)) {
        die "access denied";
    }

    my $updated_stencil = { %$stencil, %$params };

    $self->collection->update(
        { _id => MongoDB::OID->new(value => $id) },
        $updated_stencil,
        { safe => 1 }
    );

    return;
}

sub list {
    my $self = shift;
    state $check = compile(Undef|Dict[
        realm => Optional[Realm],
        author => Optional[Login],
        quests => Optional[Bool],
        # flag meaning "fetch comment_count too"; copy-pasted from db->quests->list
        comment_count => Optional[Bool],
    ]);
    my ($params) = $check->(@_);
    $params ||= {};

    my $comment_count = delete $params->{comment_count};

    my $fetch_quests = delete $params->{quests};

    my @stencils = $self->collection->find($params)->sort({ points => 1 })->all;

    $self->_prepare($_) for @stencils;
    if ($fetch_quests) {
        $self->_fill_quests($_) for @stencils;
    }

    if ($comment_count) {
        my $comment_stat = db->comments->bulk_count(
            'stencil',
            [
                map { $_->{_id} } @stencils
            ]
        );

        for my $stencil (@stencils) {
            my $cc = $comment_stat->{$stencil->{_id}};
            $stencil->{comment_count} = $cc || 0;
        }
    }

    return \@stencils;
}

sub count {
    my $self = shift;
    state $check = compile(Undef|Dict[
        realm => Realm,
    ]);
    my ($params) = $check->(@_);
    $params ||= {};

    my $count = $self->collection->find($params)->count;
    return $count;
}

sub get {
    my $self = shift;
    state $check = compile(Id, Optional[
        Dict[
            quests => Bool
        ]
    ]);
    my ($id, $options) = $check->(@_);
    $options ||= {};

    my $stencil = $self->collection->find_one({
        _id => MongoDB::OID->new(value => $id)
    });
    die "stencil $id not found" unless $stencil;

    $self->_prepare($stencil);
    $self->_fill_quests($stencil) if $options->{quests};

    return $stencil;
}

sub bulk_get {
    my $self = shift;
    state $check = compile(ArrayRef[Id]);
    my ($ids) = $check->(@_);
    # TODO - quests flag

    my @stencils = $self->collection->find({
        '_id' => {
            '$in' => [
                map { MongoDB::OID->new(value => $_) } @$ids
            ]
        }
    })->all;
    $self->_prepare($_) for @stencils;


    return {
        map {
            $_->{_id} => $_
        } @stencils
    };
}

sub take {
    my $self = shift;
    state $check = compile(Id, Login);
    my ($id, $login) = $check->(@_);

    my $stencil = $self->get($id);

    my $quest_params = {
        realm => $stencil->{realm},
        name => $stencil->{name},
        user => $login,
        stencil => $id,
        base_points => $stencil->{points},
    };
    $quest_params->{note} = $stencil->{description} if defined $stencil->{description};

    my $quest = db->quests->add($quest_params);
    return $quest;
}

1;
