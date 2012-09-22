package Play::Quests;

use Moo;
use MongoDB;
use Params::Validate qw(:all);

has 'collection' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $connection = MongoDB::Connection->new(host => 'localhost', port => 27017);
        my $db = $ENV{TEST_DB} || 'play';
        return $connection->$db->quests;
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
    $self->_prepare_quest($_) for @quests;
    return \@quests;
}

# returns new quest's id
sub add {
    my $self = shift;
    my ($params) = validate_pos(@_, { type => HASHREF });

    return $self->collection->insert($params);
}

sub update {
    my $self = shift;
    my ($id, $params) = validate_pos(@_, { type => SCALAR }, { type => HASHREF });

    my $user = $params->{user};
    die 'no user' unless $user;

    my $quest = $self->get($id);
    unless ($quest->{user} eq $user) {
        die "access denied";
    }

    delete $quest->{_id};
    $self->collection->update(
        { _id => MongoDB::OID->new(value => $id) },
        { %$quest, %$params }
    );

    return $id;
}

sub get {
    my $self = shift;
    my ($id) = validate_pos(@_, { type => SCALAR });

    my $quest = $self->collection->find_one({
        _id => MongoDB::OID->new(value => $id)
    });
    die "no such quest" unless $quest;
    $self->_prepare_quest($quest);
    return $quest;
}

1;
