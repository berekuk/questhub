use t::common;
use parent qw(Test::Class);

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
        settings => {},
    };

    http_json PUT => '/api/current_user/settings', { params => { foo => 'bar' } };
    $user = http_json GET => '/api/current_user';
    cmp_deeply $user, {
        twitter => {
            screen_name => 'blah2',
        },
        _id => re('\S+'),
        login => 'blah2',
        registered => 1,
        points => 0,
        settings => { foo => 'bar' },
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

    for my $user (qw( blah blah2 blah3 )) {
        http_json GET => "/api/fakeuser/$user";
    }

    my $user = http_json GET => '/api/user';
    cmp_deeply $user, [
        map {
            {
                twitter => {
                    screen_name => $_,
                },
                _id => re('\S+'),
                login => $_,
                points => 0,
            },
        } qw( blah blah2 blah3 )
    ];
}


sub users_list_limit_offset :Tests {
    my $self = shift;

    for my $user (map { "blah$_" } (1..5)) {
        http_json GET => "/api/fakeuser/$user";
    }

    my $gen_expected = sub {
        return [
            map {
                {
                    twitter => {
                        screen_name => $_,
                    },
                    _id => re('\S+'),
                    login => $_,
                    points => 0,
                },
            } @_
        ];
    };

    # limit
    my $user = http_json GET => '/api/user?limit=2';
    cmp_deeply $user, $gen_expected->(qw/ blah1 blah2 /);

    # offset
    my $user = http_json GET => '/api/user?limit=3&offset=1';
    cmp_deeply $user, $gen_expected->(qw/ blah2 blah3 blah4 /);

    my $result = http_json GET => '/api/user_count';
    cmp_deeply $result, { count => 5 }, 'user_count';
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

sub users_list_sort :Tests {
    my $self = shift;
    http_json GET => "/api/fakeuser/$_" for qw/ Helga Marcel Etienne /;

    my $start_quest = sub {
        my $login = shift;
        Dancer::session login => $login;
        return http_json POST => '/api/quest', { params => { name => 'build a house' } }; # returns a quest
    };
    my $finish_quest = sub {
        my $quest = shift;
        Dancer::session login => $quest->{user};
        http_json PUT => "/api/quest/$quest->{_id}", { params => {
            status => 'closed',
        } };
    };

    $start_quest->('Helga');
    # poor Marcel didn't even start anything
    $finish_quest->($start_quest->('Etienne'));

    my $get_users = sub {
        my $users = http_json GET => shift;
        return [ map { $_->{login} } @$users ];
    };

    is_deeply $get_users->('/api/user'), [ qw/ Helga Marcel Etienne / ], 'default sorting';
    is $get_users->('/api/user?sort=points&order=desc')[0], 'Etienne', 'Etienne is #1 by points score';
    is_deeply $get_users->('/api/user?sort=leaderboard'), [qw/ Etienne Helga Marcel /], 'special leaderboard sorting';
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
