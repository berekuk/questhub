package Play::DB::Stencils;

=head1 SYNOPSIS

    $stencils->add({ name => "read a book", realm => "chaos" });

=cut

use 5.014;
use utf8;

use Moo;
with
    'Play::DB::Role::Entities';

sub _build_entity_name { 'post' }; # FIXME
sub _build_entity { 'stencil' };

use Play::Mongo;
use Play::DB qw(db);
use MongoDB::OID;

use Type::Params qw( compile );
use Types::Standard qw( Undef Dict Str StrMatch Optional Bool ArrayRef );
use Play::Types qw( Id Login Realm StencilPoints );

around '_prepare' => sub {
    my $orig = shift;
    my $stencil = $orig->(@_);

    $stencil->{points} ||= 1;
    return $stencil;
};

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

    my $stencil = $self->inner_add($params);

    db->events->add({
        type => 'add-stencil',
        author => $stencil->{author},
        stencil_id => $stencil->{_id},
        realm => $stencil->{realm},
    });

    db->realms->inc_stencils($stencil->{realm});

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
        {
            _id => MongoDB::OID->new(value => $id),
            entity => $self->entity,
        },
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
        for => Optional[Login],
        # flag meaning "fetch comment_count too"; copy-pasted from db->quests->list
        comment_count => Optional[Bool],
        sort => Optional[StrMatch[ qr/^(?:points|bump)$/ ]],
    ]);
    my ($params) = $check->(@_);
    $params ||= {};
    $params->{sort} //= 'points';

    my $comment_count = delete $params->{comment_count};
    my $fetch_quests = delete $params->{quests};

    my $query = {
            map { defined($params->{$_}) ? ($_ => $params->{$_}) : () } qw/ realm author /
    };
    $query->{entity} = $self->entity;

    if (defined $params->{for}) {
        # shamelessly copy-pasted (with minor tweaks) from db->events->list and db->quests->list
        my $user = db->users->get_by_login($params->{for}) or die "User '$params->{for}' not found";

        my @subqueries;
        if ($user->{fr}) {
            push @subqueries, { realm => { '$in' => $user->{fr} } };
        }
        $user->{fu} ||= [];
        push @{ $user->{fu} }, $user->{login};
        push @subqueries, { author => { '$in' => $user->{fu} } };

        if (@subqueries) {
            $query->{'$or'} = \@subqueries;
        }
        else {
            $query->{no_such_field} = 'no_such_value';
        }
    }
    my $cursor = $self->collection->find($query);

    if ($params->{sort} eq 'points') {
        $cursor->sort({ points => 1 });
    }
    elsif ($params->{sort} eq 'bump') {
        $cursor->sort({ bump => -1 });
    }
    my @stencils = $cursor->all;

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
    $params->{entity} = $self->entity;

    my $count = $self->collection->find($params)->count;
    return $count;
}

around 'get' => sub {
    my $orig = shift;
    my $self = shift;
    state $check = compile(Id, Optional[
        Dict[
            quests => Bool
        ]
    ]);
    my ($id, $options) = $check->(@_);
    $options ||= {};

    my $stencil = $orig->($self, $id);
    $self->_fill_quests($stencil) if $options->{quests};

    return $stencil;
};

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
