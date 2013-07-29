package Play::DB::Users;

use 5.010;

use Moo;

use Log::Any qw($log);
use Digest::SHA1 qw(sha1_hex);

use Type::Params qw( compile validate );
use Types::Standard qw(Str Int Bool Dict Undef Optional HashRef);
use Play::Types qw(Login Realm);

use Play::Config qw(setting);
use Play::DB qw(db);
use Play::WWW;

with 'Play::DB::Role::Common';

=head1 METHODS

=over

=item B<get_by_twitter_login($login)>

Get a user by twitter login.

=cut
sub get_by_twitter_login {
    my $self = shift;
    my ($login) = validate(\@_, Str);

    return $self->get({ 'twitter.screen_name' => $login });
}

=item B<get_by_email($email)>

Get a user by email address.

=cut
sub get_by_email {
    my $self = shift;
    my ($email) = validate(\@_, Str);

    return $self->collection->find_one({ 'settings.email' => $email });
}

sub _prepare_user {
    my $self = shift;
    my ($user) = @_;
    $user->{_id} = $user->{_id}->to_string;
    $user->{rp} //= {};
    $user->{rp}{$_} //= 0 for @{ $user->{realms} };

    if (not $user->{twitter}{profile_image_url} and $user->{settings}{email}) {
        $user->{pic} = db->images->upic_by_email($user->{settings}{email});
    }
    elsif ($user->{twitter}{profile_image_url}) {
        $user->{pic} = db->images->upic_by_twitter_data($user->{twitter});
    }
    else {
        $user->{pic} = db->images->upic_default();
    }

    delete $user->{settings};
    return $user;
}

=item B<get($params_hashref)>

Get a user by any any parameters. Parameters are passed to mongodb as-is, beware, this method is TOO flexible.

=cut
sub get {
    my $self = shift;
    my ($params) = validate(\@_, HashRef);

    my $user = $self->collection->find_one($params);
    return unless $user;

    $self->_prepare_user($user);
    return $user;
}

=item B<get_by_login($login)>

Get a user by questhub login.

=cut
sub get_by_login {
    my $self = shift;
    my ($login) = validate(\@_, Str);
    return $self->get({ login => $login });
}

=item B<add($params)>

Add a new user.

=cut
sub add {
    my $self = shift;
    my ($params) = validate(\@_, HashRef);

    $params->{realms} ||= [];
    $params->{rp} = {
        map { $_ => 0 } @{ $params->{realms} }
    };

    my $id = $self->collection->insert($params, { safe => 1 });

    for my $realm (@{ $params->{realms} }) {
        db->events->add({
            type => 'add-user',
            author => $params->{login},
            user_id => $id->to_string,
            realm => $realm,
        });
    }

    return "$id";
}

=item B<list($params)>

Get the list of users matching the params. The only required param is I<realm>.

=cut
sub list {
    my $self = shift;
    my ($params) = validate(\@_, Undef|Dict[
        sort => Optional[Str],
        order => Optional[Str], # regex => qr/^asc|desc$/
        limit => Optional[Int],
        offset => Optional[Int],
        realm => Str,
    ]);
    $params //= {};
    $params->{order} //= 'asc';
    $params->{offset} //= 0;

    my $realm = $params->{realm};

    # fetch everyone
    # note that sorting is always by _id, see the explanation and manual sorting below
    my @users = $self->collection->find({ realms => $realm })->sort({ '_id' => 1 })->all;

    $self->_prepare_user($_) for @users;

    # filling 'open_quests' field
    my $quests = db->quests->list({ status => 'open', realm => $realm });
    my %users = map { $_->{login} => $_ } @users;
    for my $quest (@$quests) {
        for my $qlogin (@{ $quest->{team} }) {
            my $quser = $users{$qlogin};
            next unless $quser; # I guess user can be deleted and leave user-less quests behind, that's not a good reason for a failure
            $quser->{open_quests}++;
        }
    }

    # Sorting on the client side, because 'open_quests' is not a user's attribute.
    # Besides fetching the whole DB even if limit is set, this means we're N^2 on paging (see the frontend /players implementation).
    # Let's hope that Play Perl will grow popular enough that it'll need to be fixed :)
    if ($params->{sort} and $params->{sort} eq 'leaderboard') {
        # special sorting, composite points->open_quests order
        @users = sort {
            my $c1 = ($b->{rp}{$realm} || 0) <=> ($a->{rp}{$realm} || 0);
            return $c1 if $c1;
            return ($b->{open_quests} || 0) <=> ($a->{open_quests} || 0);
        } @users;
    }
    elsif ($params->{sort} and $params->{sort} eq 'points') {
        my $order_flag = ($params->{order} eq 'asc' ? 1 : -1);
        @users = sort {
            my $c = ($a->{rp}{$realm} || 0) <=> ($b->{rp}{$realm} || 0);
            return $c * $order_flag;
        } @users;
    }
    elsif (defined $params->{sort}) {
        my $order_flag = ($params->{order} eq 'asc' ? 1 : -1);
        @users = sort {
            # TODO - support string sorting
            my $c = ($a->{$params->{sort}} || 0) <=> ($b->{$params->{sort}} || 0);
            return $c * $order_flag;
        } @users;
    }

    if ($params->{limit} and @users > $params->{limit}) {
        @users = splice @users, $params->{offset}, $params->{limit};
    }

    return \@users;
}

=item B<count($params)>

Get the number of users matching the params. The only param is I<realm>.

=cut
sub count {
    my $self = shift;
    state $check = compile(Undef|Dict[
        realm => Realm,
    ]);
    my ($params) = $check->(@_);
    $params ||= {};

    $params->{realms} = delete $params->{realm};

    my $count = $self->collection->find($params)->count;
    return $count;
}

=item B<add_points($login, $amount, $realm)>

Add C<$amount> points to C<$login> on realm C<$realm>.

=cut
sub add_points {
    my $self = shift;
    my ($login, $amount, $realm) = validate(\@_, Str, Int, Str);

    my $user = $self->get_by_login($login);
    die "User '$login' not found" unless $user;
    unless (grep { $_ eq $realm } @{ $user->{realms} }) {
        $self->join_realm($login, $realm);
    }

    my $points = $user->{rp}{$realm} || 0;
    $points += $amount;

    my $id = MongoDB::OID->new(value => delete $user->{_id});
    $self->collection->update(
        { _id => $id },
        { '$set' => { "rp.$realm" => $points } },
        { safe => 1 }
    );
    return;
}

=item B<join_realm($login, $realm)>

Join a new realm.

Joining adds the realm to I<user.realms> list. The only effect of this action is that this user will be displayed in players list.

=cut
sub join_realm {
    my $self = shift;
    my ($login, $realm) = validate(\@_, Str, Str);

    db->realms->validate_name($realm);

    my $result = $self->collection->update(
        {
            login => $login,
            realms => { '$ne' => $realm },
        },
        {
            '$addToSet' => { realms => $realm },
            '$set' => { "rp.$realm" => 0 },
        },
        { safe => 1 }
    );

    my $updated = $result->{n};
    unless ($updated) {
        die "User $login not found or unable to join the realm";
    }

    db->realms->inc_users($realm); # not transactional, we may get in trouble. someone better call realms->update_stat() soon
}

=item B<follow_realm($login, $realm)>

Subscribe to a realm.

This is not the same as joining a realm. "User follows a realm" means that he or she sees its events in the news feed.

=cut
sub follow_realm {
    my $self = shift;
    my ($login, $realm) = validate(\@_, Str, Str);

    db->realms->validate_name($realm);

    my $result = $self->collection->update(
        {
            login => $login,
            fr => { '$ne' => $realm },
        },
        {
            '$addToSet' => { fr => $realm }
        },
        { safe => 1 }
    );

    my $updated = $result->{n};
    unless ($updated) {
        die "User $login not found or unable to follow the realm $realm";
    }
}

=item B<unfollow_realm($login, $realm)>

Unsubscribe from a realm.

=cut
sub unfollow_realm {
    my $self = shift;
    my ($login, $realm) = validate(\@_, Str, Str);

    db->realms->validate_name($realm);

    my $result = $self->collection->update(
        {
            login => $login,
            fr => $realm,
        },
        {
            '$pull' => { fr => $realm }
        },
        { safe => 1 }
    );

    my $updated = $result->{n};
    unless ($updated) {
        die "User $login not found or unable to unfollow the realm $realm";
    }
}

=item B<follow_user($login, $following)>

Subscribe to another user.

=cut
sub follow_user {
    my $self = shift;
    my ($login, $following) = validate(\@_, Login, Login);

    # validating that user exists
    $self->get_by_login($following) or die "User '$following' not found";

    my $result = $self->collection->update(
        {
            login => $login,
            fu => { '$ne' => $following },
        },
        {
            '$addToSet' => { fu => $following }
        },
        { safe => 1 }
    );

    my $updated = $result->{n};
    unless ($updated) {
        die "User $login not found or unable to follow the user $following";
    }

    my $email = db->users->get_email($following, 'notify_followers') or return;
    db->events->email({
        address => $email,
        subject => "$login is now following you on Questhub",
        notify_field => 'notify_followers',
        body => qq[
            <p>
            Hi $following,<br>
            <a href="].Play::WWW->player_url($login).qq[">$login</a> is now following you on Questhub.
            </p>
        ],
        login => $following,
    });
}

=item B<unfollow_user($login, $following)>

Unsubscribe from a realm.

=cut
sub unfollow_user {
    my $self = shift;
    my ($login, $following) = validate(\@_, Login, Login);

    # validating that user exists
    $self->get_by_login($following) or die "User '$following' not found";

    my $result = $self->collection->update(
        {
            login => $login,
            fu => $following,
        },
        {
            '$pull' => { fu => $following }
        },
        { safe => 1 }
    );

    my $updated = $result->{n};
    unless ($updated) {
        die "User $login not found or unable to unfollow the user $following";
    }
}

# some settings can't be set by the client
sub protected_settings {
    qw( email_confirmed api_token );
}

# some settings can't even be seen
sub secret_settings {
    qw( email_confirmation_secret );
}

sub get_settings {
    my $self = shift;
    my ($login, $secret_flag) = validate(\@_, Str, Optional[Bool]);

    my $user = $self->collection->find_one({ login => $login });
    die "User '$login' not found" unless $user;

    my $settings = $user->{settings} || {};

    unless ($secret_flag) {
        delete $settings->{$_} for secret_settings;
    }

    return $settings;
}

sub confirm_email {
    my $self = shift;
    my ($login, $secret) = validate(\@_, Str, Str);

    my $settings = $self->get_settings($login, 1);
    unless ($settings->{email_confirmation_secret}) {
        die "didn't expect email confirmation for $login";
    }

    unless ($settings->{email_confirmation_secret} eq $secret) {
        die "email confirmation secret for $login is invalid";
    }

    # already confirmed, let's stop early and avoid spamming a user with duplicate emails
    return if $settings->{email_confirmed};

    $self->collection->update(
        { login => $login },
        { '$set' =>  { 'settings.email_confirmed' => 1 } },
        { safe => 1 }
    );

    my $bool2str = sub {
        $settings->{$_[0]} ? 'enabled' : 'disabled';
    };
    db->events->email({
        address => $settings->{email},
        subject => "Your email at ".setting('service_name')." is confirmed, $login",
        body => qq[
            <p>
            Login: $login<br>
            Email: $settings->{email}<br>
            Notify about comments on your quests: ].$bool2str->('notify_comments').q[<br>
            Notify about likes on your quests: ].$bool2str->('notify_likes').q[<br>
            Notify about likes on your quests: ].$bool2str->('notify_invites').q[<br>
            Notify about new followers: ].$bool2str->('notify_followers').q[
            </p>
            <p>
            You can customize your email notifications <a href="].Play::WWW->frontpage_url().qq[">at the website</a>.
            </p>
        ],
    });
}

sub _send_email_confirmation {
    my $self = shift;
    my ($login, $email) = validate(\@_, Str, Str);

    # need email confirmation
    my $secret = int rand(100000000000);
    my $link = Play::WWW->confirm_email_url($login, $secret);
    db->events->email({
        address => $email,
        subject => "Your ".setting('service_name')." email confirmation link, $login",
        body => qq{
            <p>
            Click this if you registered on }.setting('service_name').qq{ recently: <a href="$link">$link</a>.
            </p>
            <p>
            If you think this is a mistake, just ignore this message.
            </p>
        },
    });
    return $secret;
}

sub resend_email_confirmation {
    my $self = shift;
    my ($login) = validate(\@_, Str);

    my $settings = $self->get_settings($login);
    unless ($settings->{email}) {
        die "there's no email in $login\'s settings";
    }
    $settings->{email_confirmation_secret} = $self->_send_email_confirmation($login, $settings->{email});
    $self->collection->update(
        { login => $login },
        { '$set' => { settings => $settings } },
        { safe => 1, upsert => 1 }
    );
}

=item B<set_settings($login, $settings, $persona_flag)>

Set C<$login>'s settings to C<$settings>. Auto-confirm email if C<$persona_flag> is set.

=cut
sub set_settings {
    my $self = shift;
    my ($login, $settings, $persona) = validate(\@_, Str, HashRef, Optional[Bool]);

    # some settings can't be set by the client
    delete $settings->{$_} for secret_settings, protected_settings;
    delete $settings->{user}; # just to avoid the confusion, nobody uses this field anyway (since we merged user_settings and users collections)

    my $old_settings = $self->get_settings($login, 1);

    if ($persona) {
        $settings->{email_confirmed} = 'persona';
    }
    else {
        if ($settings->{email}) {

            if ($old_settings->{email} and $old_settings->{email} eq $settings->{email}) {
                # changing non-email settings -> confirmation status is not lost
                for (secret_settings, protected_settings) {
                    $settings->{$_} = $old_settings->{$_} if exists $old_settings->{$_};
                }
            }
            else {
                $log->info('need email confirmation');
                $settings->{email_confirmation_secret} = $self->_send_email_confirmation($login, $settings->{email});
            }
        }
    }
    # preserving protected_settings minus email_confirmed - do we need more facets of special settings?
    for (qw( api_token )) {
        $settings->{$_} = $old_settings->{$_} if exists $old_settings->{$_};
    }

    my $result = $self->collection->update(
        { login => $login },
        { '$set' => { settings => $settings } },
        { safe => 1 }
    );
    my $updated = $result->{n};
    unless ($updated) {
        die "Unable to update settings for $login";
    }
    return;
}

sub set_setting {
    my $self = shift;
    my ($login, $setting, $value) = validate(\@_, Login, Str, Str);
    $setting =~ /^[\w-]+$/ or die "Invalid setting name '$setting'"; # preventing mongo injections - special values such as '$unset'

    die "Forbidden setting '$setting'" if grep { $_ eq $setting } (secret_settings, protected_settings);

    my $result = $self->collection->update(
        { login => $login },
        { '$set' => { "settings.$setting" => $value } },
        { safe => 1 }
    );
    my $updated = $result->{n};
    unless ($updated) {
        die "User $login not found?";
    }
    return;
}

sub generate_api_token {
    my $self = shift;
    my ($login) = validate(\@_, Login);

    my $token = join '', map { sprintf "%x", rand 16 } 1..32;
    my $result = $self->collection->update(
        { login => $login },
        { '$set' => { "settings.api_token" => $token } },
        { safe => 1 }
    );
    my $updated = $result->{n};
    unless ($updated) {
        die "User $login not found";
    }
    return $token;
}

sub get_email {
    my $self = shift;
    my ($login, $notify_field) = validate(\@_, Str, Str);

    my $settings = $self->get_settings($login);
    return unless $settings->{$notify_field};
    return unless $settings->{email_confirmed};
    return $settings->{email};
}

sub unsubscribe {
    my $self = shift;
    my ($params) = validate(\@_, Dict[
        login => Str,
        notify_field => Str,
        secret => Str,
    ]);

    die "secret key is wrong" unless $params->{secret} eq $self->unsubscribe_secret($params->{login});

    my $result = $self->collection->update(
        { login => $params->{login} },
        { '$set' => { "settings.$params->{notify_field}" => 0 } },
        { safe => 1 }
    );
    unless ($result->{n}) {
        die "User $params->{login} not found or already unsubscribed";
    }

    return;
}

sub unsubscribe_secret {
    my $self = shift;
    my ($login) = @_;

    return sha1_hex(setting('unsubscribe_salt').':'.$login);
}

sub stat {
    my $self = shift;
    state $check = compile(Login);
    my ($login) = $check->(@_);

    my $stat = {};

    my $quests = db->quests->list({ user => $login });
    for my $status (qw/ closed open abandoned /) {
        $stat->{$status} = scalar grep { $_->{status} eq $status } @$quests;
    }
    return {
        quests => $stat
    };
}

sub autocomplete {
    my $self = shift;
    state $check = compile(Login); # any prefix of login is login too, right? (unless we require login to be N characters long, oops)
    my ($prefix) = $check->(@_);

    my @users = $self->collection->find({
        login => {
            '$regex' => "^$prefix"
        }
    }, { login => 1 })->limit(5)->all;

    return [ sort map { $_->{login} } @users ];
}

=back

=cut

1;
