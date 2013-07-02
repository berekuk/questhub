use lib 'lib';
use Play::Test::App;
use Play::DB qw(db);

use parent qw(Test::Class);

sub setup :Tests(setup) {
    reset_db();
    Dancer::session->destroy;
}

sub users_list_empty :Tests {
    my $users = http_json GET => '/api/user?realm=europe';
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
    cmp_deeply $user, superhashof({
        twitter => {
            screen_name => 'blah2',
        },
        _id => re('\S+'),
        login => 'blah2',
        registered => 1,
        rp => {
            europe => 0,
            asia => 0,
        },
        settings => {},
        notifications => [],
        realms => ['europe', 'asia'],
    });

    http_json PUT => '/api/current_user/settings', { params => { foo => 'bar' } };
    $user = http_json GET => '/api/current_user';
    cmp_deeply $user, superhashof({
        twitter => {
            screen_name => 'blah2',
        },
        _id => re('\S+'),
        login => 'blah2',
        registered => 1,
        rp => {
            europe => 0,
            asia => 0,
        },
        settings => { foo => 'bar' },
        notifications => [],
        realms => ['europe', 'asia'],
    });

    db->notifications->add('blah2', 'shout', 'preved');
    db->notifications->add('blah2', 'shout', 'medved');

    $user = http_json GET => '/api/current_user';
    cmp_deeply $user, superhashof({
        twitter => {
            screen_name => 'blah2',
        },
        _id => re('\S+'),
        login => 'blah2',
        registered => 1,
        rp => {
            europe => 0,
            asia => 0,
        },
        settings => { foo => 'bar' },
        notifications => [
            superhashof({ params => 'preved' }),
            superhashof({ params => 'medved' }),
        ],
        realms => ['europe', 'asia'],
    });

}

sub another_user :Tests {
    my $self = shift;
    $self->_add_users;

    my $user = http_json GET => '/api/user/blah';
    cmp_deeply $user, superhashof({
        twitter => {
            screen_name => 'blah',
        },
        _id => re('\S+'),
        login => 'blah',
        rp => {
            europe => 0,
            asia => 0,
        },
        realms => ['europe', 'asia'],
    });
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

    my $user = http_json GET => '/api/user?realm=europe';
    cmp_deeply $user, [
        map {
            {
                twitter => {
                    screen_name => $_,
                },
                _id => re('\S+'),
                login => $_,
                rp => {
                    europe => 0,
                    asia => 0,
                },
                realms => ['europe', 'asia'],
                pic => ignore,
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
                    rp => {
                        europe => 0,
                        asia => 0,
                    },
                    realms => ['europe', 'asia'],
                    pic => {
                        small => ignore,
                        normal => ignore,
                    },
                },
            } @_
        ];
    };

    # limit
    my $user = http_json GET => '/api/user?realm=europe&limit=2';
    cmp_deeply $user, $gen_expected->(qw/ blah1 blah2 /);

    # offset
    $user = http_json GET => '/api/user?realm=europe&limit=3&offset=1';
    cmp_deeply $user, $gen_expected->(qw/ blah2 blah3 blah4 /);
}

sub open_quests_count :Tests {
    my $self = shift;
    $self->_add_users;

    Dancer::session login => 'blah';
    http_json POST => '/api/quest', { params => {
        user => 'blah',
        name => 'q1',
        realm => 'europe',
    } };
    http_json POST => '/api/quest', { params => {
        user => 'blah',
        name => 'q2',
        realm => 'europe',
    } };
    http_json POST => '/api/quest', { params => {
        user => 'blah',
        name => 'a1',
        realm => 'asia',
    } };

    my $user = http_json GET => '/api/user?realm=europe';
    cmp_deeply $user, [
        superhashof({
            twitter => {
                screen_name => 'blah',
            },
            _id => re('\S+'),
            login => 'blah',
            rp => {
                europe => 0,
                asia => 0,
            },
            open_quests => 2, # asia quest doesn't count
            realms => ['europe', 'asia'],
        }),
        superhashof({
            twitter => {
                screen_name => 'blah2',
            },
            _id => re('\S+'),
            login => 'blah2',
            rp => {
                europe => 0,
                asia => 0,
            },
            realms => ['europe', 'asia'],
        }),
    ];
}

sub users_list_sort :Tests {
    my $self = shift;
    http_json GET => "/api/fakeuser/$_" for qw/ Helga Marcel Etienne /;

    my $start_quest = sub {
        my $login = shift;
        Dancer::session login => $login;
        # returns a quest
        return http_json POST => '/api/quest', { params => {
            name => 'build a house',
            realm => 'europe',
        } };
    };
    my $finish_quest = sub {
        my $quest = shift;
        Dancer::session login => $quest->{team}[0];
        http_json POST => "/api/quest/$quest->{_id}/close";
    };

    $start_quest->('Helga');
    # poor Marcel didn't even start anything
    $finish_quest->($start_quest->('Etienne'));

    my $get_users = sub {
        my $users = http_json GET => shift;
        return [ map { $_->{login} } @$users ];
    };

    is_deeply
        $get_users->('/api/user?realm=europe'),
        [ qw/ Helga Marcel Etienne / ],
        'default sorting';

    is
        $get_users->('/api/user?realm=europe&sort=points&order=desc')[0],
        'Etienne',
        'Etienne is #1 by points score';

    is_deeply
        $get_users->('/api/user?realm=europe&sort=leaderboard'),
        [qw/ Etienne Helga Marcel /],
        'special leaderboard sorting';
}

sub register :Tests {
    my $current_user = http_json GET => '/api/current_user';
    cmp_deeply $current_user, { registered => 0 };

    # register user without settings
    Dancer::session twitter_user => { screen_name => 'twah' };
    $current_user = http_json GET => '/api/current_user';
    cmp_deeply $current_user, {
        registered => 0,
        twitter => {
            screen_name => 'twah',
        },
    };

    my $result = http_json POST => '/api/register', { params => {
        login => 'blah'
    } };
    cmp_deeply $result, superhashof({ status => 'ok' });

    $current_user = http_json GET => '/api/current_user';
    cmp_deeply $current_user, superhashof({
        registered => 1,
        _id => re('^\S+$'),
        rp => {},
        login => 'blah',
        twitter => {
            screen_name => 'twah',
        },
        settings => {},
        notifications => [],
        realms => [],
    });
}

sub register_dups :Tests {
    Dancer::session twitter_user => { screen_name => 'foo' };

    my $result = http_json POST => '/api/register', { params => {
        login => 'blah',
        realm => 'asia',
        settings => encode_json({ email => 'foo@example.com' }),
    } };
    http_json POST => '/api/logout';

    Dancer::session twitter_user => { screen_name => 'foo2' };

    $result = http_json POST => '/api/register', { params => {
        login => 'blah',
        realm => 'asia',
        settings => encode_json({ email => 'foo@example.com' }),
    } };

    cmp_deeply $result, superhashof({ status => 'conflict', reason => 'login' });
    cmp_deeply http_json(GET => '/api/current_user'), superhashof({ registered => 0 });

    $result = http_json POST => '/api/register', { params => {
        login => 'blah2',
        realm => 'asia',
        settings => encode_json({ email => 'foo@example.com' }),
    } };

    cmp_deeply $result, superhashof({ status => 'conflict', reason => 'email' });
    cmp_deeply http_json(GET => '/api/current_user'), superhashof({ registered => 0 });
}

sub register_settings :Tests {
    Dancer::session twitter_user => { screen_name => 'twit' };
    my $settings = {
        email => 'foo@example.com',
        notify_likes => 0,
        notify_comments => 1,
        email_confirmed => 1,
    };

    http_json POST => '/api/register', { params => {
        login => 'foo',
        realm => 'europe',
        settings => encode_json($settings),
    } };

    my $got_settings = http_json GET => '/api/current_user/settings';
    cmp_deeply $got_settings, {
        email => 'foo@example.com',
        notify_likes => 0,
        notify_comments => 1,
        # no email_confirmed - important!
    };

    # TODO - try the same with email_confirmed=persona, since persona is special
}

sub register_persona :Tests {
    Dancer::session persona_email => 'example@mozilla.com';

    http_json POST => '/api/register', { params => {
        login => 'Gary',
        realm => 'europe',
    } };

    my $current_user = http_json GET => '/api/current_user';
    cmp_deeply $current_user, superhashof({
        registered => 1,
        login => 'Gary',
        settings => superhashof({
            email => 'example@mozilla.com',
            email_confirmed => 'persona',
        }),
    });
}

sub register_cancel :Tests {
    Dancer::session persona_email => 'example@mozilla.com';
    is Dancer::session('persona_email'), 'example@mozilla.com';

    http_json POST => '/api/register/cancel';
    is Dancer::session('persona_email'), undef;
}

sub register_login_validation :Tests {
    Dancer::session twitter_user => { screen_name => 'twah' };
    my $response = dancer_response POST => '/api/register', { params => {
        login => 'John Doe',
        realm => 'europe',
    } };
    is $response->status, 400, 'spaces in logins are forbidden';
}

sub perl_get_by_email :Tests {
    # register user with settings
    Dancer::session->destroy;
    Dancer::session twitter_user => { screen_name => 'john' };
    my $settings = {
        email => 'jack@example.com',
        notify_likes => 0,
        notify_comments => 1,
    };

    http_json POST => '/api/register', { params => {
        login => 'jack',
        realm => 'europe',
        settings => encode_json($settings),
    } };

    my $user = db->users->get_by_email('jack@example.com');
    is $user, 'jack', 'get_by_email returns login';
}

sub dismiss_notification :Tests {
    my $self = shift;

    $self->_add_users;
    my $id1 = db->notifications->add('blah2', 'shout', 'preved');
    my $id2 = db->notifications->add('blah2', 'shout', 'medved');

    http_json POST => "/api/current_user/dismiss_notification/$id2";

    my $current_user = http_json GET => '/api/current_user';
    cmp_deeply $current_user, superhashof({
        registered => 1,
        login => 'blah2',
        notifications => [
            superhashof({ params => 'preved' }),
        ],
    });
}

sub pic :Tests {
    my $response = dancer_response GET => '/api/user/foo/pic?s=normal';
    is $response->status, 200;
    is $response->content_type, 'image/jpg';
}

sub follow_realm :Tests {
    http_json GET => "/api/fakeuser/$_" for qw/ foo bar /;

    my $current_user = http_json GET => '/api/current_user';
    cmp_deeply $current_user, superhashof({
        login => 'bar',
    });
    ok not $current_user->{fr};

    http_json POST => "/api/follow_realm/europe";
    $current_user = http_json GET => '/api/current_user';
    cmp_deeply $current_user, superhashof({
        fr => ['europe'],
    });
}

sub unfollow_realm :Tests {
    http_json GET => "/api/fakeuser/foo";

    http_json POST => "/api/follow_realm/europe";
    http_json POST => "/api/follow_realm/asia";
    http_json POST => "/api/unfollow_realm/asia";

    my $current_user = http_json GET => '/api/current_user';
    cmp_deeply $current_user, superhashof({
        fr => ['europe'],
    });
}

sub follow_unfollow_user :Tests {
    http_json GET => "/api/fakeuser/foo";
    http_json GET => "/api/fakeuser/bar";
    http_json GET => "/api/fakeuser/baz";

    http_json POST => "/api/user/bar/follow";
    http_json POST => "/api/user/baz/follow";
    my $current_user = http_json GET => '/api/current_user';
    cmp_deeply $current_user, superhashof({
        fu => ['bar', 'baz'],
    });

    http_json POST => "/api/user/baz/unfollow";
    $current_user = http_json GET => '/api/current_user';
    cmp_deeply $current_user, superhashof({
        fu => ['bar'],
    });
}

sub settings :Tests {
    http_json GET => "/api/fakeuser/foo";

    http_json POST => "/api/settings/set/blah/5";
    my $got_settings = http_json GET => '/api/current_user/settings';
    cmp_deeply $got_settings, { blah => 5 };

    http_json POST => "/api/settings/set/duh/6";
    $got_settings = http_json GET => '/api/current_user/settings';
    cmp_deeply $got_settings, { blah => 5, duh => 6 };
}

sub stat :Tests {
    my $self = shift;
    http_json GET => "/api/fakeuser/foo";

    http_json POST => '/api/quest', { params => {
        name => 'q1',
        realm => 'europe',
    } };

    my $stat = http_json GET => '/api/user/foo/stat';
    cmp_deeply $stat, {
        quests => {
            open => 1,
            closed => 0,
            abandoned => 0,
        }
    };

}

__PACKAGE__->new->runtests;
