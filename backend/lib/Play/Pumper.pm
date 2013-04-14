package Play::Pumper;

use Moo::Role;
with
    'Moo::Runnable::Looper',
    'Moo::Runnable::WithStat';

use Lock::File 'lockfile';
use Play::Config qw(setting);
use Scalar::Util qw(blessed);

has 'pumper_name' => (
    is => 'lazy',
    default => sub {
        my $self = shift;
        my $pumper_name = blessed $self;
        $pumper_name =~ s{^bin::pumper::(\w+)$}{$1} or die "Unexpected package name: '$pumper_name'";
        return $pumper_name;
    }
);

around 'run' => sub {
    my $orig = shift;
    my $self = shift;

    my $pumper_name = $self->pumper_name;

    my $lock;
    unless (setting('test')) {
        $lock = lockfile("/data/pumper/$pumper_name.lock", { blocking => 0 }) or return;
    }

    $orig->($self, @_);
};

1;
