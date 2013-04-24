use 5.010;

use lib 'lib';
use Play::Test::App;
use parent qw(Test::Class);

use Play::DB qw(db);
use XML::LibXML;

sub setup :Tests(setup => no_plan) {
    Dancer::session->destroy;
    reset_db();
}

sub _fill_common_quests {
    my $self = shift;
    my $quests_data = {
        1 => {
            name    => 'name_1',
            user    => 'user_1',
            status  => 'open',
        },
        2 => {
            name    => 'name_2',
            user    => 'user_2',
            status  => 'open',
            tags    => ['bug'],
        },
        3 => {
            name    => 'name_3',
            user    => 'user_3',
            status  => 'closed',
        },
    };

    # insert quests to DB
    for (keys %$quests_data) {
        delete $quests_data->{$_}{_id};
        my $result = db->quests->add($quests_data->{$_});
        $quests_data->{$_}{_id} = $result->{_id};
        $quests_data->{$_}{ts} = $result->{ts};
        $quests_data->{$_}{team} = $result->{team};
        delete $quests_data->{$_}{user};

        http_json GET => "/api/fakeuser/$quests_data->{$_}{team}[0]";
    }
    return $quests_data;
}

sub quest_list :Tests {
    my @quests = (
        {
            name    => 'name_1',
            status  => 'open',
        },
        {
            name    => 'name_2',
            status  => 'open',
            tags    => ['bug'],
        },
        {
            name    => 'name_3',
            status  => 'closed',
        },
    );

    http_json GET => "/api/fakeuser/foo";
    http_json POST => '/api/quest', { params => $_ } for @quests;

    my $list = http_json GET => '/api/quest';

    cmp_deeply
        [
            sort { $a->{_id} cmp $b->{_id} } @$list
        ],
        [
            map {
                {
                    %$_,
                    author => 'foo',
                    team => ['foo'],
                    _id => ignore,
                    ts => re('^\d+$'),
                    status => 'open' # original status is ignored
                }
            } @quests
        ];
}

sub quest_list_filtering :Tests {
    my $self = shift;

    http_json GET => "/api/fakeuser/foo";
    my @quests = map { http_json POST => '/api/quest', { params => { name => "foo-$_" } } } 1..5;
    http_json PUT => "/api/quest/$quests[$_]->{_id}", { params => { status => 'closed' } } for 3, 4;
    http_json PUT => "/api/quest/$quests[1]->{_id}", { params => { tags => ['t1'] } };
    http_json PUT => "/api/quest/$quests[3]->{_id}", { params => { tags => ['t1', 't2'] } };

    http_json GET => "/api/fakeuser/bar";
    http_json POST => "/api/quest/$quests[$_]->{_id}/watch" for 0, 4;
    http_json GET => "/api/fakeuser/baz";
    http_json POST => "/api/quest/$quests[$_]->{_id}/watch" for 2, 4;

    my $list = http_json GET => '/api/quest', { params => { status => 'closed' } };
    cmp_deeply
        [ map { $_->{_id} } @$list ],
        [ map { $_->{_id} } @quests[4,3] ];

    $list = http_json GET => '/api/quest', { params => { tags => 't1' } };
    cmp_deeply
        [ map { $_->{_id} } @$list ],
        [ map { $_->{_id} } @quests[3,1] ];

    $list = http_json GET => '/api/quest', { params => { watchers => 'bar' } };
    cmp_deeply
        [ map { $_->{_id} } @$list ],
        [ map { $_->{_id} } @quests[4,0] ];
}

sub quest_sorting :Tests {
    my $self = shift;
    my $quests_data = $self->_fill_common_quests;

    http_json GET => '/api/fakeuser/user_3';
    http_json POST => '/api/quest/'.$quests_data->{2}{_id}.'/like';
    http_json POST => '/api/quest/'.$quests_data->{1}{_id}.'/comment', { params => { body => 'bah!' } };

    my $list = http_json GET => '/api/quest?sort=leaderboard';
    my @names = map { $_->{name} } @$list;
    is_deeply \@names, [qw/ name_2 name_1 name_3 /];
}

sub quest_list_limit_offset :Tests {
    my $self = shift;
    my $quests_data = $self->_fill_common_quests;

    my $list = http_json GET => '/api/quest?limit=2';
    is scalar @$list, 2;

    $list = http_json GET => '/api/quest?limit=2&offset=2';
    is scalar @$list, 1;

    $list = http_json GET => '/api/quest?limit=5';
    is scalar @$list, 3;
}

sub single_quest :Tests {
    my $self = shift;
    my $quests_data = $self->_fill_common_quests;

    my $id          =  $quests_data->{1}{_id};
    my $quest = http_json GET => '/api/quest/'.$id;

    cmp_deeply $quest, superhashof($quests_data->{1});
}

sub edit_quest :Tests {
    my $self = shift;
    my $quests_data = $self->_fill_common_quests;

    my $edited_quest = $quests_data->{1};
    my $id          = $edited_quest->{_id};
    local $edited_quest->{name} = 'name_11'; # Change

    Dancer::session login => $edited_quest->{team}[0];

    my $put_result = http_json PUT => "/api/quest/$id", { params => { name => $edited_quest->{name} } };
    cmp_deeply $put_result, { _id => $id }, 'put result';

    my $got_quest = http_json GET => "/api/quest/$id";
    cmp_deeply $got_quest, superhashof($edited_quest);
}


sub add_quest :Tests {
    my $user = 'user_4';
    my $new_record = {
        name    => 'name_4',
        status  => 'open',
    };

    Dancer::session login => $user;

    my $add_result = http_json POST => '/api/quest', { params => $new_record };

    cmp_deeply
        $add_result,
        { %$new_record, team => [$user], author => $user, _id => re('^\S+$'), ts => re('^\d+$') },
        'add response';

    my $id = $add_result->{_id};

    my $got_quest = http_json GET => "/api/quest/$id";
    cmp_deeply
        $got_quest,
        { %$new_record, team => [$user], author => $user, _id => re('^\S+$'), ts => re('^\d+$') },
        'get response';
}

sub quest_events :Tests {

    my $user = 'euser';
    http_json GET => "/api/fakeuser/$user";

    my $new_record = {
        name    => 'test-quest',
        status  => 'open',
    };

    Dancer::session login => $user;
    my $add_result = http_json POST => '/api/quest', { params => $new_record }; # create
    my $quest_id = $add_result->{_id};
    http_json PUT => "/api/quest/$quest_id", { params => { status => 'closed' } }; # close
    http_json PUT => "/api/quest/$quest_id", { params => { status => 'open' } }; # and reopen again
    http_json PUT => "/api/quest/$quest_id", { params => { status => 'abandoned' } };
    http_json PUT => "/api/quest/$quest_id", { params => { status => 'open' } };

    my @events = grep { $_->{object_type} eq 'quest' } @{ db->events->list };
    cmp_deeply \@events, [
        {
            _id => re('^\S+$'),
            ts => re('^\d+$'),
            object_type => 'quest',
            action => 'resurrect',
            author => $user,
            object_id => $quest_id,
            object => superhashof({ name => 'test-quest', status => 'open', team => [$user], author => $user }),
        },
        {
            _id => re('^\S+$'),
            ts => re('^\d+$'),
            object_type => 'quest',
            action => 'abandon',
            author => $user,
            object_id => $quest_id,
            object => superhashof({ name => 'test-quest', status => 'abandoned', team => [$user], author => $user }),
        },
        {
            _id => re('^\S+$'),
            ts => re('^\d+$'),
            object_type => 'quest',
            action => 'reopen',
            author => $user,
            object_id => $quest_id,
            object => superhashof({ name => 'test-quest', status => 'open', team => [$user], author => $user }),
        },
        {
            _id => re('^\S+$'),
            ts => re('^\d+$'),
            object_type => 'quest',
            action => 'close',
            author => $user,
            object_id => $quest_id,
            object => superhashof({ name => 'test-quest', status => 'closed', team => [$user], author => $user }),
        },
        {
            _id => re('^\S+$'),
            ts => re('^\d+$'),
            object_type => 'quest',
            action => 'add',
            author => $user,
            object_id => $quest_id,
            object => superhashof({ name => 'test-quest', status => 'open', team => [$user], author => $user }),
        },
    ];
}

sub delete_quest :Tests {
    my $self = shift;
    my $quests_data = $self->_fill_common_quests;

    my $id_to_remove;
    my $user;
    {
        my $list_before_resp = dancer_response GET => '/api/quest';
        my $result = decode_json($list_before_resp->content);
        is scalar @$result, 3;
        $id_to_remove = $result->[1]{_id};
        $user = $result->[1]{team}[0];
        like $id_to_remove, qr/^[0-9a-f]{24}$/; # just an assertion
    }

    {
        my $delete_resp = dancer_response DELETE => "/api/quest/$id_to_remove";
        is $delete_resp->status, 500, "Can't delete a quest while not logged in";
    }

    {
        Dancer::session login => 'blah';
        http_json GET => "/api/fakeuser/blah";
        my $delete_resp = dancer_response DELETE => "/api/quest/$id_to_remove";
        is $delete_resp->status, 500, "Can't delete another user's quest";
    }

    {
        Dancer::session login => $user;
        http_json GET => "/api/fakeuser/$user";
        my $delete_resp = dancer_response DELETE => "/api/quest/$id_to_remove";
        is $delete_resp->status, 200, "Can delete the quest you own" or diag $delete_resp->content;
    }

    {
        my $list_after_resp = dancer_response GET => '/api/quest';
        is scalar @{ decode_json($list_after_resp->content) }, 2, 'deleted quests are not shown in list';
    }

    {
        my $delete_resp = dancer_response GET => "/api/quest/$id_to_remove";
        is $delete_resp->status, 500, "Can't fetch a deleted quest by its id";
    }
}

sub points :Tests {
    my $self = shift;
    my $quests_data = $self->_fill_common_quests;

    my $quest = $quests_data->{1}; # name_2, user_2

    http_json GET => "/api/fakeuser/".$quest->{team}[0];
    Dancer::session login => $quest->{team}[0];

    my $user = http_json GET => '/api/current_user';
    is $user->{points}, 0;

    http_json PUT => "/api/quest/$quest->{_id}", { params => { status => 'closed' } };

    $user = http_json GET => '/api/current_user';
    is $user->{points}, 1, 'got a point';

    http_json PUT => "/api/quest/$quest->{_id}", { params => { status => 'open' } };
    $user = http_json GET => '/api/current_user';
    is $user->{points}, 0, 'lost a point';

    my $like = sub {
        my ($quest, $user, $action) = @_;
        my $old_login = Dancer::session('login');
        http_json GET => "/api/fakeuser/$user";
        Dancer::session login => $user;
        http_json POST => "/api/quest/$quest->{_id}/$action";
        Dancer::session login => $old_login;
    };
    $like->($quest, 'other', 'like');
    $like->($quest, 'other2', 'like');

    $user = http_json GET => '/api/current_user';
    is $user->{points}, 0, 'no points for likes on an open quest';

    http_json PUT => "/api/quest/$quest->{_id}", { params => { status => 'closed' } };
    $user = http_json GET => '/api/current_user';
    is $user->{points}, 3, '1 + number-of-likes points for a closed quest';

    $like->($quest, 'other', 'unlike');
    $like->($quest, 'other3', 'like');
    $like->($quest, 'other4', 'like');
    $user = http_json GET => '/api/current_user';
    is $user->{points}, 4, 'likes and unlikes apply to the closed quest, retroactively';

    http_json PUT => "/api/quest/$quest->{_id}", { params => { status => 'open' } };
    $user = http_json GET => '/api/current_user';
    is $user->{points}, 0, 'points are taken away if quest is reopened';

    http_json PUT => "/api/quest/$quest->{_id}", { params => { status => 'closed' } };
    $user = http_json GET => '/api/current_user';
    is $user->{points}, 4, 'closed again, got points again...';

    http_json DELETE => "/api/quest/$quest->{_id}";
    $user = http_json GET => '/api/current_user';
    is $user->{points}, 0, 'lost points after delete';
}

sub more_points :Tests {
    my $self = shift;
    my $quests_data = $self->_fill_common_quests;

   my $quest = $quests_data->{1};
    http_json GET => "/api/fakeuser/$quest->{team}[0]";

    my $user = http_json GET => '/api/current_user';
    is $user->{points}, 0, 'zero points initially';

    http_json DELETE => "/api/quest/$quest->{_id}";
    $user = http_json GET => '/api/current_user';
    is $user->{points}, 0, 'still zero points after removing an open quest';
}

sub quest_tags :Tests {
    Dancer::session login => 'user_1';

    http_json POST => '/api/quest', { params => {
        name => 'typed-quest',
        tags => ['blog', 'moose'],
    } };

    my $unknown_type_response = dancer_response POST => '/api/quest', { params => {
        name => 'typed-quest',
        tags => 'invalid',
    } };
    is $unknown_type_response->status, 500;
    like $unknown_type_response->content, qr/not one of the allowed types: arrayref/;
}

sub cc :Tests {
    my $user = 'user_c';
    http_json GET => "/api/fakeuser/$user";
    Dancer::session login => $user;

    my $q1_result = http_json POST => '/api/quest', { params => {
        name => 'q1',
    } };
    my $q2_result = http_json POST => '/api/quest', { params => {
        name => 'q2',
    } };
    my $q3_result = http_json POST => '/api/quest', { params => {
        name => 'q3',
    } };

    http_json POST => "/api/quest/$q1_result->{_id}/comment", { params => { body => 'first comment!' } };
    http_json POST => "/api/quest/$q1_result->{_id}/comment", { params => { body => 'second comment on first quest!' } };
    http_json POST => "/api/quest/$q3_result->{_id}/comment", { params => { body => 'first comment on third quest!' } };

    my $list = http_json GET => "/api/quest?user=$user";
    my $list_with_cc = http_json GET => "/api/quest?user=$user&comment_count=1";
    is $list->[0]{comment_count}, undef;

    # default order is desc, so $list_with_cc->[0] is q3
    is $list_with_cc->[0]{comment_count}, 1;
    is $list_with_cc->[1]{comment_count}, undef;
    is $list_with_cc->[2]{comment_count}, 2;
}

sub email_like :Tests {

    http_json GET => "/api/fakeuser/foo";

    register_email 'foo' => { email => 'test@example.com', notify_comments => 0, notify_likes => 1 };

    my $quest = http_json POST => '/api/quest', { params => {
        name => 'q1',
    } };

    http_json GET => "/api/fakeuser/bar";

    http_json POST => "/api/quest/$quest->{_id}/like";

    my @deliveries = process_email_queue();
    is scalar(@deliveries), 1, '1 email sent';
    my $email = $deliveries[0];
    cmp_deeply $email->{envelope}, {
        from => 'notification@localhost',
        to => [ 'test@example.com' ],
    }, 'from & to addresses';

    like
        $email->{email}->get_body,
        qr/Reward for completing this quest is now 2/,
        'reward line in email body';

    # now let's close the quest and like it once more

    Dancer::session login => 'foo';
    $quest = http_json PUT => "/api/quest/$quest->{_id}", { params => {
        status => 'closed',
    } };

    http_json GET => "/api/fakeuser/bar2";

    http_json POST => "/api/quest/$quest->{_id}/like";

    @deliveries = process_email_queue();
    is scalar(@deliveries), 1, 'second email sent';
    $email = $deliveries[0];
    unlike
        $email->{email}->get_body,
        qr/Reward for completing this quest/,
        "no reward line in emails on completed quest's like";
    like
        $email->{email}->get_body,
        qr/you get one more point/,
        "'already completed' text in email";
}

sub join_leave :Tests {
    http_json GET => "/api/fakeuser/foo";

    my $quest = http_json POST => '/api/quest', { params => {
        name => 'q1',
    } };

    my $response;

    $response = dancer_response POST => "/api/quest/$quest->{_id}/join";
    is $response->status, 500;
    like $response->content, qr/unable to join a quest/;

    http_json POST => "/api/quest/$quest->{_id}/leave";

    my $got_quest = http_json GET => "/api/quest/$quest->{_id}";
    is $got_quest->{name}, 'q1', 'name is still untouched';
    is_deeply $got_quest->{team}, [], 'team is empty too';

    $response = dancer_response POST => "/api/quest/$quest->{_id}/leave";
    is $response->status, 500;
    like $response->content, qr/unable to leave quest/;

    my $list = http_json GET => "/api/quest?unclaimed=1";
    cmp_deeply $list, [$got_quest], 'listing unclaimed=1 option';

    http_json POST => "/api/quest/$quest->{_id}/like";

    http_json GET => "/api/fakeuser/bar";
    http_json POST => "/api/quest/$quest->{_id}/like";

    Dancer::session login => 'foo';

    $got_quest = http_json GET => "/api/quest/$quest->{_id}";
    is_deeply $got_quest->{likes}, ['foo', 'bar'];

    http_json POST => "/api/quest/$quest->{_id}/join";
    $list = http_json GET => "/api/quest?unclaimed=1";
    is scalar @$list, 0;

    $got_quest = http_json GET => "/api/quest/$quest->{_id}";
    is_deeply $got_quest->{likes}, ['bar'], 'joining means unliking';

    Dancer::session login => 'foo2';
    $response = dancer_response POST => "/api/quest/$quest->{_id}/join";
    is $response->status, 500;
    like $response->content, qr/unable to join a quest/;

    Dancer::session login => 'foo';
    http_json POST => "/api/quest/$quest->{_id}/invite", { params => {
        invitee => 'foo2',
    } };

    Dancer::session login => 'foo2';
    http_json POST => "/api/quest/$quest->{_id}/join";

    $got_quest = http_json GET => "/api/quest/$quest->{_id}";
    is_deeply $got_quest->{team}, ['foo', 'foo2'], '/join added user to the team';

    http_json POST => "/api/quest/$quest->{_id}/invite", { params => {
        invitee => 'bar',
    } };
    http_json POST => "/api/quest/$quest->{_id}/uninvite", { params => {
        invitee => 'bar',
    } };

    Dancer::session login => 'bar';
    $response = dancer_response POST => "/api/quest/$quest->{_id}/join";
    is $response->status, 500, 'invitation was cancelled';
    like $response->content, qr/unable to join a quest/, 'failed /join body';
}

sub watch_unwatch :Tests {
    http_json GET => "/api/fakeuser/foo";

    my $quest = http_json POST => '/api/quest', { params => {
        name => 'q1',
    } };

    my $response;

    $response = dancer_response POST => "/api/quest/$quest->{_id}/watch";
    is $response->status, 500;
    like $response->content, qr/unable to watch/;

    $response = dancer_response POST => "/api/quest/$quest->{_id}/unwatch";
    is $response->status, 500;
    like $response->content, qr/unable to unwatch/;

    http_json GET => "/api/fakeuser/bar";
    http_json POST => "/api/quest/$quest->{_id}/watch";

    my $got_quest = http_json GET => "/api/quest/$quest->{_id}";
    cmp_deeply $got_quest->{watchers}, ['bar'], 'bar is a watcher now';

    http_json GET => "/api/fakeuser/baz";
    http_json POST => "/api/quest/$quest->{_id}/watch";

    $got_quest = http_json GET => "/api/quest/$quest->{_id}";
    cmp_deeply $got_quest->{watchers}, ['bar', 'baz'], 'baz is a watcher now too';

    http_json POST => "/api/quest/$quest->{_id}/unwatch";
    $got_quest = http_json GET => "/api/quest/$quest->{_id}";
    cmp_deeply $got_quest->{watchers}, ['bar'], 'baz is not a watcher anymore';
}

sub email_watchers :Tests {

    http_json GET => "/api/fakeuser/foo";
    register_email('foo' => { email => "foo\@example.com", notify_comments => 1 });

    my $quest = http_json POST => '/api/quest', { params => {
        name => 'q1',
    } };

    for my $user (qw/ bar baz buzz /) {
        http_json GET => "/api/fakeuser/$user";
        http_json POST => "/api/quest/$quest->{_id}/watch";
        register_email($user => { email => "$user\@example.com", notify_comments => 1 });
    }

    http_json POST => '/api/quest/'.$quest->{_id}.'/comment', { params => { body => 'hello to foo, bar and baz!' } };

    pumper('events2email')->run;
    my @deliveries = process_email_queue();
    is scalar @deliveries, 3;

    cmp_deeply
        [ sort map { $_->{successes}[0] } @deliveries ],
        [ sort map { "$_\@example.com" } qw( foo bar baz ) ];
}

sub atom :Tests {
    http_json GET => '/api/fakeuser/foo';

    http_json POST => '/api/quest', { params => {
        name => 'q1',
        status => 'open',
    } };
    http_json POST => '/api/quest', { params => {
        name => 'q2',
        status => 'open',
    } };

    # Regular Atom
    my $response = dancer_response GET => '/api/quest?fmt=atom&user=foo';
    is $response->status, 200;
    is exception { XML::LibXML->new->parse_string($response->content) }, undef;
}

__PACKAGE__->new->runtests;
