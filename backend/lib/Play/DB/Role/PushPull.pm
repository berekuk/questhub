package Play::DB::Role::PushPull;

=head1 SYNOPSIS

    use Play::DB::Role::PushPull;
    with PushPull(field => 'likes', except_field => 'user', push => 'like', pull => 'unlike');

=cut

use Package::Variant
    importing => ['Moo::Role'],
    subs => [qw( with has )];

use Scalar::Util qw(blessed);
use Params::Validate qw(:all);

sub make_variant {
    my ($class, $target_package, %params) = @_;

    for (qw( field except_field push_method pull_method )) {
        $params{$_} or die "'$_' parameter expected";
    }

    my $field = $params{field};
    my $except_field = $params{except_field};
    my $pull_method = $params{pull_method};
    my $push_method = $params{push_method};

    with 'Play::DB::Role::Common';

    my $push_or_pull = sub {
        my $self = shift;
        my ($id, $user, $mode, $method) = @_;

        my $check;
        $check = { '$ne' => $user } if $mode eq '$addToSet';
        $check = $user if $mode eq '$pull';
        die "unexpected mode '$mode'" unless defined $check;

        my $result = $self->collection->update(
            {
                _id => MongoDB::OID->new(value => $id),
                $except_field => { '$ne' => $user },
                $field => $check,
            },
            {
                $mode => { $field => $user },
            },
            { safe => 1 }
        );
        my $updated = $result->{n};
        unless ($updated) {
            die ucfirst($self->entity_name)." not found or unable to $method your own ".$self->entity_name;
        }
        return;
    };

    install $push_method => sub {
        my $self = shift;
        my ($id, $user) = validate_pos(@_, { type => SCALAR }, { type => SCALAR });

        $push_or_pull->($self, $id, $user, '$addToSet', $push_method);
        return;
    };

    install $pull_method => sub {
        my $self = shift;
        my ($id, $user) = validate_pos(@_, { type => SCALAR }, { type => SCALAR });

        $push_or_pull->($self, $id, $user, '$pull', $pull_method);
        return;
    };
}

1;
