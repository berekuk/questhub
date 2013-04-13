package Moo::Runnable::Looper;

use Moo::Role;
use MooX::Options;
with 'Moo::Runnable';

option 'loop' => (
    is => 'ro',
);

option 'sleep_period' => (
    is => 'ro',
    format => 'i',
    default => sub { 1 },
);

sub run {
    my $self = shift;

    # loopers are often used as ubic services;
    # ubic services are reloaded on logrotate with SIGHUP, so it makes sense to default to IGNORE
    $SIG{HUP} = 'IGNORE';

    if ($self->loop) {
        # TODO - SIGTERM support
        while (1) {
            $self->run_once;
            sleep $self->sleep_period;
        }
    }
    else {
        $self->run_once;
    }
}

1;
