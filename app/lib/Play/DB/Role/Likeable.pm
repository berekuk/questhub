package Play::DB::Role::Likeable;

use Moo::Role;
use Scalar::Util qw(blessed);

use Params::Validate qw(:all);

has 'entity_owner_field' => (
    is => 'lazy',
);

has 'entity_name' => (
    is => 'lazy',
);
sub _build_entity_name {
    my $self = shift;
    my $package = blessed $self;
    $package =~ s{.*::(\w+)s$}{$1} or die "unexpected package '$package'";
    return lcfirst $package;
}

# returns the entity that was liked
sub _like_or_unlike {
    my $self = shift;
    my ($id, $user, $mode) = @_;

    my $result = $self->collection->update(
        {
            _id => MongoDB::OID->new(value => $id),
            $self->entity_owner_field => { '$ne' => $user },
        },
        { $mode => { likes => $user } },
        { safe => 1 }
    );
    my $updated = $result->{n};
    unless ($updated) {
        die ucfirst($self->entity_name)." not found or unable to like your own ".$self->entity_name;
    }
    return;
}

sub like {
    my $self = shift;
    my ($id, $user) = validate_pos(@_, { type => SCALAR }, { type => SCALAR });

    $self->_like_or_unlike($id, $user, '$addToSet');
    return;
}

sub unlike {
    my $self = shift;
    my ($id, $user) = validate_pos(@_, { type => SCALAR }, { type => SCALAR });

    $self->_like_or_unlike($id, $user, '$pull');
    return;
}


1;
