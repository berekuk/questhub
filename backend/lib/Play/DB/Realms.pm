package Play::DB::Realms;

use 5.010;
use Moo;

use Type::Params qw(validate);
use Play::Config qw(setting);
use Types::Standard qw(Str);

sub validate_name {
    my $self = shift;
    my ($realm) = validate(\@_, Str);

    unless (grep { $realm eq $_ } @{ setting('realms') }) {
        die "Unknown realm '$realm'";
    }
}

1;
