use lib 'lib';
use Play::Test::App;
use parent qw(Test::Class);

sub setup :Tests(setup) {
    reset_db();
    process_email_queue();
    Dancer::session->destroy;
}

sub get_settings_no_login :Tests {
    my $response = dancer_response GET => '/api/current_user/settings';
    is $response->status, 500;
}

sub get_settings_empty :Tests {

    for my $user (qw/ foo bar /) {
        http_json GET => "/api/fakeuser/$user";
    }

    Dancer::session login => 'foo';
    my $settings = http_json GET => '/api/current_user/settings';
    cmp_deeply $settings, {};
}

sub set_settings :Tests {

    for my $user (qw/ foo bar /) {
        http_json GET => "/api/fakeuser/$user";
    }

    Dancer::session login => 'foo';
    http_json PUT => '/api/current_user/settings', { params => {
        email => 'me@berekuk.ru', notify_likes => 1,
    } };
    my $settings;
    $settings = http_json GET => '/api/current_user/settings';
    cmp_deeply $settings, {
        email => 'me@berekuk.ru',
        notify_likes => 1,
    }, 'new settings';

    http_json PUT => '/api/current_user/settings', { params => {
        overwrite => 1,
    } };
    $settings = http_json GET => '/api/current_user/settings';
    cmp_deeply $settings, {
        overwrite => 1,
    }, 'updating settings overwrites them completely';

    http_json POST => '/api/current_user/settings', { params => {
        overwrite => 2,
    } };
    $settings = http_json GET => '/api/current_user/settings';
    cmp_deeply $settings, {
        overwrite => 2,
    }, 'POST is the same as PUT';

    Dancer::session login => 'bar';
    http_json PUT => '/api/current_user/settings', { params => {
        a => 'b', user => 'foo' # attempt to hack foo's settings
    } };
    $settings = http_json GET => '/api/current_user/settings';
    cmp_deeply $settings, {
        a => 'b',
    }, 'bar edited his own settings despite his attempt to break the app';

    Dancer::session login => 'foo';
    $settings = http_json GET => '/api/current_user/settings';
    cmp_deeply $settings, {
        overwrite => 2,
    }, 'foo settings are intact';
}

sub _email_to_secret {
    my ($email) = @_;
    my ($secret) = $email->{email}->get_body =~ qr/(\d+)</;
    return $secret;
}

sub email_confirmation :Tests {
    # TODO - check how email confirmation code works with the real /api/register
    http_json GET => "/api/fakeuser/foo";

    http_json PUT => '/api/current_user/settings', { params => {
        email => 'someone@somewhere.com',
        notify_likes => 1,
        notify_comments => 1,
        email_confirmed => 1,
        email_confirmation_secret => 'iddqd',
    } };

    my $settings = http_json GET => '/api/current_user/settings';
    cmp_deeply $settings, {
        email => 'someone@somewhere.com',
        notify_likes => 1,
        notify_comments => 1,
    }, "user can't change secret or protected settings";

    my $response = dancer_response POST => '/api/register/confirm_email', { params => { login => 'bar', secret => 'iddqd' } };
    is $response->status, 500;
    like $response->content, qr/User 'bar' not found/, 'no confirmation for non-existing user';

    $response = dancer_response POST => '/api/register/confirm_email', { params => { login => 'foo', secret => 'iddqd' } };
    is $response->status, 500;
    like $response->content, qr/secret for foo is invalid/;

    my @deliveries = process_email_queue();
    is scalar(@deliveries), 1, 'registration email received';
    cmp_deeply $deliveries[0]->{envelope}, {
        from => 'notification@localhost',
        to => [ 'someone@somewhere.com' ],
    }, 'from & to addresses';
    my ($secret) = _email_to_secret($deliveries[0]);
    ok $secret, 'parsed secret key from email';

    # before we confirm the email, lets check that other emails are not sent before confirmation
    {
        my $quest = http_json POST => '/api/quest', { params => {
            name => 'q1',
            realm => 'europe',
        } };
        http_json GET => "/api/fakeuser/bar";
        Dancer::session login => 'bar';

        http_json POST => "/api/quest/$quest->{_id}/like";
        is(scalar(process_email_queue()), 0);
        Dancer::session login => 'foo';
    }

    http_json POST => '/api/register/confirm_email', { params => { login => 'foo', secret => $secret } }; # yay, confirmed
    $settings = http_json GET => '/api/current_user/settings';
    cmp_deeply $settings, superhashof({
        email => 'someone@somewhere.com',
        email_confirmed => 1,
    }), "email_confirmed flag in settings";

    # TODO - check contents
    is(scalar(process_email_queue()), 1, "confirmation's confirmation email");

    # now other emails are working
    {
        my $quest = http_json POST => '/api/quest', { params => {
            name => 'q2',
            realm => 'europe',
        } };
        Dancer::session login => 'bar';

        http_json POST => "/api/quest/$quest->{_id}/like";
        is(scalar(process_email_queue()), 1);
    }

    # TODO - check that further email changes reset the confirmation status!
}

sub resend_email_confirmation :Tests {
    http_json GET => "/api/fakeuser/foo";

    http_json PUT => '/api/current_user/settings', { params => {
        email => 'someone@somewhere.com',
    } };

    my @deliveries = process_email_queue();
    is scalar(@deliveries), 1;
    my ($secret) = _email_to_secret($deliveries[0]);
    ok $secret, 'got secret';

    http_json POST => '/api/register/resend_email_confirmation';
    my $response = dancer_response POST => '/api/register/confirm_email', { params => { login => 'foo', secret => $secret } };
    is $response->status, 500, 'old secret is invalid after email resending';

    @deliveries = process_email_queue();
    is scalar(@deliveries), 1;
    ($secret) = _email_to_secret($deliveries[0]);
    ok $secret, 'got a new secret';
    $response = dancer_response POST => '/api/register/confirm_email', { params => { login => 'foo', secret => $secret } };
    is $response->status, 200, 'new secret is fine';
}

sub unsubscribe :Tests {
    http_json GET => "/api/fakeuser/foo";

    http_json PUT => '/api/current_user/settings', { params => {
        email => 'someone@somewhere.com',
        notify_comments => 1,
        notify_likes => 1,
    } };

    my @deliveries = process_email_queue();
    is scalar(@deliveries), 1;
    my ($secret) = _email_to_secret($deliveries[0]);

    my $response = dancer_response GET => '/api/user/foo/unsubscribe/notify_likes';
    is $response->status, 500, "can't unsubscribe without a secret key";
    like $response->content, qr/secret is not set/;

    $response = dancer_response GET => '/api/user/foo/unsubscribe/notify_likes?secret=123';
    is $response->status, 302, "wrong unsubscribe redirects";
    like $response->header('location'), qr{/player/foo/unsubscribe/notify_likes/fail$}, '...to the fail page';

    my $settings = http_json GET => '/api/current_user/settings';
    is $settings->{notify_likes}, 1;

    $response = dancer_response GET => "/api/user/foo/unsubscribe/notify_likes?secret=$secret";
    is $response->status, 302, "correct unsubscribe redirects too";
    like $response->header('location'), qr{/player/foo/unsubscribe/notify_likes/ok$}, '...to the ok page';

    $settings = http_json GET => '/api/current_user/settings';
    is $settings->{notify_likes}, 0;
}

__PACKAGE__->new->runtests;
