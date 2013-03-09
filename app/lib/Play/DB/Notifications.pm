package Play::DB::Notifications;

use Moo;
use Params::Validate qw(:all);

use Play::DB;

has 'collection' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        return Play::Mongo->db->get_collection('notifications');
    },
);

sub _prepare {
    my $self = shift;
    my ($object) = @_;
    $object->{ts} = $object->{_id}->get_time;
    $object->{_id} = $object->{_id}->to_string;
    return $object;
}

sub add {
    my $self = shift;
    my ($login, $type, $params) = validate_pos(@_, { type => SCALAR }, { type => SCALAR }, 1);
    # TODO - stricter notification types

    my $id = $self->collection->insert({
        user => $login,
        type => $type,
        params => $params,
    });
    return $id->to_string;
}

sub list {
    my $self = shift;
    my ($login) = validate_pos(@_, { type => SCALAR });

    my @notifications = $self->collection->find({ user => $login })->all;
    $self->_prepare($_) for @notifications;

    return \@notifications;
}

sub remove {
    my $self = shift;
    my ($id, $login) = validate_pos(@_, { type => SCALAR }, { type => SCALAR });

    my $result = $self->collection->remove(
        {
            _id => MongoDB::OID->new(value => $id),
            user => $login,
        },
        { just_one => 1, safe => 1 }
    );

    die "notification not found or access denied" unless $result->{n} == 1;
    return;
}

1;
