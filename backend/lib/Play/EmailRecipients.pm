package Play::EmailRecipients;

use Moo;

use Types::Standard -types;
use Type::Params qw(validate);

has '_recipients' => (
    is => 'ro',
    isa => HashRef,
    default => sub { {} },
);

sub add_logins {
    my $self = shift;
    my ($logins, $reason) = validate(\@_, ArrayRef[Str], Str);

    my $recipients = $self->_recipients;
    for my $login (@$logins) {
        $self->_recipients->{$login} ||= {
            login => $login,
            reason => $reason,
        };
    }
    return;
}

sub exclude {
    my $self = shift;
    my ($login) = validate(\@_, Str);

    delete $self->_recipients->{$login};
    return;
}

sub get_all {
    my $self = shift;
    validate(\@_);

    return values %{ $self->_recipients };
}

1;
