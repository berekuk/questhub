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
use Play::Types qw( Id Login Realm );

sub _prepare {
    my $self = shift;
    my ($stencil) = @_;
    $stencil->{ts} = $stencil->{_id}->get_time;
    $stencil->{_id} = $stencil->{_id}->to_string;

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
    ]);
    my ($params) = $check->(@_);

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

    return $stencil;
}

sub list {
    my $self = shift;
    state $check = compile(Undef|Dict[
        realm => Optional[Realm],
        author => Optional[Login],
        quests => Optional[Bool],
    ]);
    my ($params) = $check->(@_);
    $params ||= {};

    my $fetch_quests = delete $params->{quests};

    my @stencils = $self->collection->find($params)->all;

    $self->_prepare($_) for @stencils;
    if ($fetch_quests) {
        $self->_fill_quests($_) for @stencils;
    }

    return \@stencils;
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
    };
    $quest_params->{description} = $stencil->{description} if defined $stencil->{description};

    my $quest = db->quests->add($quest_params);
    return $quest;
}

1;
