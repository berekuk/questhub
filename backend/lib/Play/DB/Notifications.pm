package Play::DB::Notifications;

use 5.010;

use Moo;

use Types::Standard qw(Str HashRef Any);
use Type::Params qw(validate);

use Play::DB;

with 'Play::DB::Role::Common';

sub _prepare {
    my $self = shift;
    my ($object) = @_;
    $object->{ts} = $object->{_id}->get_time;
    $object->{_id} = $object->{_id}->to_string;
    return $object;
}

sub add {
    my $self = shift;
    my ($login, $type, $params) = validate(\@_, Str, Str, Any);
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
    my ($login) = validate(\@_, Str);

    my @notifications = $self->collection->find({ user => $login })->all;
    $self->_prepare($_) for @notifications;

    return \@notifications;
}

sub remove {
    my $self = shift;
    my ($id, $login) = validate(\@_, Str, Str);

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
