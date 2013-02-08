package Play::Events;

use Moo;
use Play::Mongo;
use Params::Validate qw(:all);

has 'collection' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        return Play::Mongo->db->get_collection('events');
    },
);

sub _prepare_event {
    my $self = shift;
    my ($event) = @_;
    $event->{ts} = $event->{_id}->get_time;
    $event->{_id} = $event->{_id}->to_string;
    return $event;
}

sub add {
    my $self = shift;
    my ($event) = validate_pos(@_, { type => HASHREF });

    my $id = $self->collection->insert($event);
    return 1;
}

# returns last 100 events
# TODO: pager
sub list {
    my $self = shift;
    validate_pos(@_);

    my @events = $self->collection->query->sort({ _id => -1 })->limit(100)->all;
    $self->_prepare_event($_) for @events;

    return \@events;
}

1;
