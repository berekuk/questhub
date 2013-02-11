use t::common;
use parent qw(Test::Class);

use Play::Users;

sub setup :Tests(setup) {
    reset_db();
    Dancer::session->destroy;
}

sub users_list_empty :Tests {
    my $users = http_json GET => '/api/user';
    cmp_deeply $users, [];
}

sub _add_users {
    for my $user (qw( blah blah2 )) {
        http_json GET => "/api/fakeuser/$user";
    }
}

sub current_user :Tests {
    my $self = shift;
    $self->_add_users;

    my $user = http_json GET => '/api/current_user';
    cmp_deeply $user, {
        twitter => {
            screen_name => 'blah2',
        },
        _id => re('\S+'),
        login => 'blah2',
        registered => 1,
        points => 0,
    };
}

sub another_user :Tests {
    my $self = shift;
    $self->_add_users;

    my $user = http_json GET => '/api/user/blah';
    cmp_deeply $user, {
        twitter => {
            screen_name => 'blah',
        },
        _id => re('\S+'),
        login => 'blah',
        points => 0,
    };
}

sub nonexistent_user :Tests {
    my $self = shift;
    $self->_add_users;

    my $response = dancer_response GET => '/api/user/nosuchuser';
    is $response->status, 500;
    like $response->content, qr/user .* not found/;
}

sub logout :Tests {
    my $self = shift;
    $self->_add_users;

    http_json post => '/api/logout';

    my $user = http_json get => '/api/current_user';
    cmp_deeply $user, { registered => 0 };
}

sub users_list :Tests {
    my $self = shift;
    $self->_add_users;

    my $user = http_json GET => '/api/user';
    cmp_deeply $user, [
        {
            twitter => {
                screen_name => 'blah',
            },
            _id => re('\S+'),
            login => 'blah',
            points => 0,
        },
        {
            twitter => {
                screen_name => 'blah2',
            },
            _id => re('\S+'),
            login => 'blah2',
            points => 0,
        },
    ];
}

sub open_quests_count :Tests {
    my $self = shift;
    $self->_add_users;

    Dancer::session login => 'blah';
    http_json POST => '/api/quest', { params => { user => 'blah', name => 'q1' } };
    http_json POST => '/api/quest', { params => { user => 'blah', name => 'q2' } };

    my $user = http_json GET => '/api/user';
    cmp_deeply $user, [
        {
            twitter => {
                screen_name => 'blah',
            },
            _id => re('\S+'),
            login => 'blah',
            points => 0,
            open_quests => 2,
        },
        {
            twitter => {
                screen_name => 'blah2',
            },
            _id => re('\S+'),
            login => 'blah2',
            points => 0,
        },
    ];
}

sub register :Tests {
    # register user without settings
    Dancer::session twitter_user => { screen_name => 'twah' };
    http_json POST => '/api/register', { params => {
        login => 'blah'
    } };

    # register user with settings
    Dancer::session->destroy;
    Dancer::session twitter_user => { screen_name => 'twit' };
    my $settings = {
        email => 'twat@example.com',
        notify_likes => 0,
        notify_comments => 1,
    };

    http_json POST => '/api/register', { params => {
        login => 'twat',
        settings => encode_json($settings),
    } };

    Dancer::session login => 'twat';
    my $got_settings = http_json GET => '/api/current_user/settings';
    cmp_deeply $got_settings, superhashof($settings);
}

__PACKAGE__->new->runtests;
