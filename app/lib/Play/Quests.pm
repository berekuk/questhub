package Play::Quests;

use Moo;
use MongoDB;
use Params::Validate qw(:all);

has 'collection' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $connection = MongoDB::Connection->new(host => 'localhost', port => 27017);
        return $connection->play->quests;
    },
);

sub list {
    my $self = shift;
    my ($user) = validate_pos(@_, { type => SCALAR });

    my @quests = $self->collection->find({ user => $user })->all;
    $_->{_id} = $_->{_id}->to_string for @quests;
    return \@quests;
}

# returns new quest's id
sub add {
    my $self = shift;
    my ($params) = validate_pos(@_, { type => HASHREF });

    return $self->collection->insert($params);
}

sub get {
    my $self = shift;
    my ($id) = validate_pos(@_, { type => SCALAR });

    my $quest = $self->collection->find_one({ _id => $id });
    return $quest;

}

1;
