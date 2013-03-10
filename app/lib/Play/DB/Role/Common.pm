package Play::DB::Role::Common;

use Moo::Role;

has 'entity_name' => (
    is => 'lazy',
);
sub _build_entity_name {
    my $self = shift;
    my $package = blessed $self;
    $package =~ s{.*::(\w+)s$}{$1} or die "unexpected package '$package'";
    return lcfirst $package;
}

1;
