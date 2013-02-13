use t::common;
use parent qw(Test::Class);

use Play::Users;

sub setup :Tests(setup) {
    reset_db();
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

sub email_confirmation :Tests {
    http_json GET => "/api/fakeuser/foo";
    Dancer::session login => 'foo';

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

    my $response = dancer_response GET => '/api/user/bar/confirm_email/iddqd';
    is $response->status, 500;
    like $response->content, qr/didn't expect email confirmation/, 'no confirmation for non-existing user';

    $response = dancer_response GET => '/api/user/foo/confirm_email/iddqd';
    is $response->status, 500;
    like $response->content, qr/secret for foo is invalid/;

    my @deliveries = Email::Sender::Simple->default_transport->deliveries;
    is scalar(@deliveries), 1, 'registration email received';
    cmp_deeply $deliveries[0]->{envelope}, {
        from => 'notification@play-perl.org',
        to => [ 'someone@somewhere.com' ],
    }, 'from & to addresses';
    my ($secret) = $deliveries[0]->{email}->get_body =~ qr/(\d+)</;
    ok $secret, 'parsed secret key from email';
    Email::Sender::Simple->default_transport->clear_deliveries;

    # before we confirm the email, lets check that other emails are not sent before confirmation
    {
        my $quest = http_json POST => '/api/quest', { params => {
            name => 'q1',
        } };
        http_json GET => "/api/fakeuser/bar";
        Dancer::session login => 'bar';

        http_json POST => "/api/quest/$quest->{_id}/like";
        is(Email::Sender::Simple->default_transport->delivery_count, 0);
        Dancer::session login => 'foo';
    }

    http_json GET => "/api/user/foo/confirm_email/$secret"; # yay, confirmed
    my $settings = http_json GET => '/api/current_user/settings';
    cmp_deeply $settings, superhashof({
        email => 'someone@somewhere.com',
        email_confirmed => 1,
    }), "email_confirmed flag in settings";

    # now other emails are working
    {
        my $quest = http_json POST => '/api/quest', { params => {
            name => 'q2',
        } };
        Dancer::session login => 'bar';

        http_json POST => "/api/quest/$quest->{_id}/like";
        is(Email::Sender::Simple->default_transport->delivery_count, 1);
    }
}

__PACKAGE__->new->runtests;
