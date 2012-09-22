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

sub get {
    my $self = shift;
    my ($id) = validate_pos(@_, { type => SCALAR });

    my $quest = $self->collection->find_one({
        _id => MongoDB::OID->new(value => $id)
    });
    $self->_prepare_quest($quest);
    return $quest;

}

1;
