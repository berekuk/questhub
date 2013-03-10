package Play::DB::Role::Common;

use Moo::Role;

use Scalar::Util qw(blessed);
use Play::Mongo;

has 'entity_name' => (
    is => 'lazy',
);
sub _build_entity_name {
    my $self = shift;
    my $package = blessed $self;
    $package =~ s{.*::(\w+)s$}{$1} or die "unexpected package '$package'";
    return lcfirst $package;
}

has 'collection' => (
    is => 'lazy',
);
sub _build_collection {
    my $self = shift;
    return Play::Mongo->db->get_collection($self->entity_name.'s');
}

1;
