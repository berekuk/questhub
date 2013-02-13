package Play::Users;

use Moo;
use Params::Validate qw(:all);
use Play::Mongo;

use Play::Events;
use Play::Quests; # recursive dependency!

my $events = Play::Events->new;

has 'settings_collection' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        return Play::Mongo->db->get_collection('user_settings');
    },
);

has 'collection' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        return Play::Mongo->db->get_collection('users');
    },
);

my $quests = Play::Quests->new;

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

    # filling 'open_quests' field
    my $quests = $quests->list({ status => 'open' });
    my %users = map { $_->{login} => $_ } @users;
    for my $quest (@$quests) {
        my $quser = $users{ $quest->{user} };
        next unless $quser; # I guess user can be deleted and leave user-less quests behind, that's not a good reason for a failure
        $quser->{open_quests}++;
    }

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

# some settings can't be set by the client
sub protected_settings {
    qw( email_confirmed );
}

# some settings can't even be seen
sub secret_settings {
    qw( email_confirmation_secret );
}

sub get_settings {
    my $self = shift;
    my ($login) = validate_pos(@_, { type => SCALAR });

    my $settings = $self->settings_collection->find_one({ user => $login });
    $settings ||= {};
    delete $settings->{_id}; # nobody cares about settings _id

    delete $settings->{$_} for secret_settings, 'user';

    return $settings;
}

sub confirm_email {
    my $self = shift;
    my ($login, $secret) = validate_pos(@_, { type => SCALAR }, { type => SCALAR });

    my $settings = $self->settings_collection->find_one({ user => $login });
    unless ($settings->{email_confirmation_secret}) {
        die "didn't expect email confirmation for $login";
    }

    unless ($settings->{email_confirmation_secret} eq $secret) {
        die "email confirmation secret for $login is invalid";
    }

    $self->settings_collection->update(
        { user => $login },
        { '$set' =>  { 'email_confirmed' => 1 } },
        { safe => 1 }
    );

    my $bool2str = sub {
        $settings->{$_[0]} ? 'enabled' : 'disabled';
    };
    $events->email(
        $settings->{email},
        "Email at Play Perl is confirmed, $login",
        qq[
            <p>
            Login: $login<br>
            Email: $settings->{email}<br>
            Notify about likes on your quests: ].$bool2str->('notify_likes').q[<br>
            Notify about comments on your quests: ].$bool2str->('notify_likes').q[
            </p>
            <p>
            You can customize email notifications <a href="http://play-perl.org">at the website</a>.
            </p>
        ]
    );
}

sub _send_email_confirmation {
    my $self = shift;
    my ($login, $email) = validate_pos(@_, { type => SCALAR }, { type => SCALAR });

    # need email confirmation
    my $secret = int rand(100000000000);
    my $link = "http://play-perl.org/register/confirm/$login/$secret";
    $events->email(
        $email,
        "Your Play Perl registration link, $login",
        qq{
            Here you go: <a href="$link">$link</a>.
        }
    );
    return $secret;
}

sub resend_email_confirmation {
    my $self = shift;
    my ($login) = validate_pos(@_, { type => SCALAR });

    my $settings = $self->get_settings($login);
    unless ($settings->{email}) {
        die "there's no email in $login\'s settings";
    }
    $settings->{email_confirmation_secret} = $self->_send_email_confirmation($login, $settings->{email});
    $self->settings_collection->update(
        { user => $login },
        { %$settings, user => $login },
        { safe => 1, upsert => 1 }
    );
}

sub set_settings {
    my $self = shift;
    my ($login, $settings) = validate_pos(@_, { type => SCALAR }, { type => HASHREF });

    # some settings can't be set by the client
    delete $settings->{$_} for protected_settings, secret_settings;

    my $old_settings = $self->get_settings($login);
    for (protected_settings) {
        $settings->{$_} = $old_settings->{$_} if exists $old_settings->{$_};
    }

    if (
        $settings->{email} and (
            not $old_settings->{email}
            or $old_settings->{email} ne $settings->{email}
        )
    ) {
        # need email confirmation
        $settings->{email_confirmation_secret} = $self->_send_email_confirmation($login, $settings->{email});
    }

    $self->settings_collection->update(
        { user => $login },
        { %$settings, user => $login },
        { safe => 1, upsert => 1 }
    );
}

sub get_email {
    my $self = shift;
    my ($login, $notify_field) = validate_pos(@_, { type => SCALAR }, { type => SCALAR });

    my $settings = $self->get_settings($login);
    return unless $settings->{$notify_field};
    return unless $settings->{email_confirmed};
    return $settings->{email};
}

1;
