package Play::Users;

use Moo;
use Params::Validate qw(:all);
use Play::Mongo;

has 'collection' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        return Play::Mongo->db->get_collection('users');
    },
);

sub get_by_twitter_login {
    my $self = shift;
    my ($login) = validate_pos(@_, { type => SCALAR });

    return $self->get({ twitter => { screen_name => $login } });
}

sub _prepare_user {
    my $self = shift;
    my ($user) = @_;
    $user->{_id} = $user->{_id}->to_string;
    $user->{points} ||= 0;
    return $user;
}

sub get {
    my $self = shift;
    my ($params) = validate_pos(@_, { type => HASHREF });

    my $user = $self->collection->find_one($params);
    return unless $user;

    $self->_prepare_user($user);
    return $user;
}

sub get_by_login {
    my $self = shift;
    my ($login) = validate_pos(@_, { type => SCALAR });
    return $self->get({ login => $login });
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
    $self->_prepare_user($_) for @users;
    return \@users;
}

sub add_points {
    my $self = shift;
    my ($login, $amount) = validate_pos(@_, { type => SCALAR }, { type => SCALAR, regex => qr/^-?\d+$/, default => 1 });

    my $user = $self->get_by_login($login);
    die "User '$login' not found" unless $user;

    my $points = $user->{points} || 0;
    $points += $amount;

    my $id = MongoDB::OID->new(value => delete $user->{_id});
    $self->collection->update(
        { _id => $id },
        { %$user, points => $points },
        { safe => 1 }
    );
}

1;
