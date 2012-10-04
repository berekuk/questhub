package Play::Users;

use Moo;
use Params::Validate qw(:all);
use Play::Mongo;

has 'collection' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        return Play::Mongo->db->users;
    },
);

# unlike ->get, this function returns undef if it doesn't find a user
sub get_by_twitter_login {
    my $self = shift;
    my ($login) = validate_pos(@_, { type => SCALAR });
    my $user = $self->collection->find_one({ twitter => { login => $login } });
    return unless $user;

    $user->{_id} = "$user->{_id}";
    return $user;
}

sub get {
    my $self = shift;
    my ($params) = validate_pos(@_, { type => HASHREF });

    my $user = $self->collection->find_one($params);
    return unless $user;

    $user->{_id} = "$user->{_id}";
    return $user;
}

sub add {
    my $self = shift;
    my ($params) = validate_pos(@_, { type => HASHREF });

    my $id = $self->collection->insert($params);
    return "$id";
}

sub list {
    my $self = shift;
    my ($params) = validate_pos(@_);
    my @users = $self->collection->find({})->all;
    $_->{_id} = "$_->{_id}" for @users;
    return \@users;
}

1;
