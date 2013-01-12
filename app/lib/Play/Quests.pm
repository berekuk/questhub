package Play::Quests;

use Moo;
use Params::Validate qw(:all);
use Play::Mongo;

use Play::Users;

my $users = Play::Users->new;

has 'collection' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        return Play::Mongo->db->get_collection('quests');
    },
);

sub _prepare_quest {
    my $self = shift;
    my ($quest) = @_;
    $quest->{_id} = $quest->{_id}->to_string;
    return $quest;
}

sub list {
    my $self = shift;
    my ($params) = validate_pos(@_, { type => HASHREF });

    my @quests = $self->collection->find($params)->all;
    @quests = grep { $_->{status} ne 'deleted' } @quests;

    $self->_prepare_quest($_) for @quests;
    return \@quests;
}

# returns new quest's id
sub add {
    my $self = shift;
    my ($params) = validate_pos(@_, { type => HASHREF });

    # validate
    # TODO - do strict validation here instead of dancer route?
    if ($params->{type}) {
        die "Unexpected quest type '$params->{type}'" unless grep { $params->{type} eq $_ } qw/ bug blog feature other /;
    }

    my $id = $self->collection->insert($params);
    return $id->to_string;
}

sub update {
    my $self = shift;
    my ($id, $params) = validate_pos(@_, { type => SCALAR }, { type => HASHREF });

    my $user = $params->{user};
    die 'no user' unless $user;

    # FIXME - rewrite to modifier-based atomic update!
    my $quest = $self->get($id);
    unless ($quest->{user} eq $user) {
        die "access denied";
    }

    if ($quest->{status} eq 'open' and $params->{status} and $params->{status} eq 'closed') {
        $users->add_points($user, 1);
    }

    # reopen
    if ($quest->{status} eq 'closed' and $params->{status} and $params->{status} eq 'open') {
        $users->add_points($user, -1);
    }

    delete $quest->{_id};
    $self->collection->update(
        { _id => MongoDB::OID->new(value => $id) },
        { %$quest, %$params }
    );

    return $id;
}

sub _like_or_unlike {
    my $self = shift;
    my ($id, $user, $mode) = @_;

    my $result = $self->collection->update(
        {
            _id => MongoDB::OID->new(value => $id),
            user => { '$ne' => $user },
        },
        { $mode => { likes => $user } },
        { safe => 1 }
    );
    my $updated = $result->{n};
    unless ($updated) {
        die "Quest not found or unable to like your own quest";
    }
    return;
}

sub like {
    my $self = shift;
    my ($id, $user) = validate_pos(@_, { type => SCALAR }, { type => SCALAR });

    return $self->_like_or_unlike($id, $user, '$addToSet');
}

sub unlike {
    my $self = shift;
    my ($id, $user) = validate_pos(@_, { type => SCALAR }, { type => SCALAR });

    return $self->_like_or_unlike($id, $user, '$pull');
}

sub remove {
    my $self = shift;
    my ($id, $params) = validate_pos(@_, { type => SCALAR }, { type => HASHREF });

    my $user = $params->{user};
    die 'no user' unless $user;

    # FIXME - rewrite to modifier-based atomic update!
    my $quest = $self->get($id);
    unless ($quest->{user} eq $user) {
        die "access denied";
    }

    delete $quest->{_id};
    $self->collection->update(
        { _id => MongoDB::OID->new(value => $id) },
        { %$quest, status => 'deleted' },
        { safe => 1 }
    );
}

sub get {
    my $self = shift;
    my ($id) = validate_pos(@_, { type => SCALAR });

    my $quest = $self->collection->find_one({
        _id => MongoDB::OID->new(value => $id)
    });
    die "quest $id not found" unless $quest;
    $self->_prepare_quest($quest);
    return $quest;
}

1;
