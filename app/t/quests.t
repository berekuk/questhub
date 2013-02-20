use t::common;
use parent qw(Test::Class);

use Play::Quests;
use Play::Events;

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
    },
    3 => {
        name    => 'name_3',
        user    => 'user_3',
        status  => 'closed',
    },
};

sub setup :Tests(setup) {

    my $quests = Play::Quests->new;

    Dancer::session->destroy;
    reset_db();

    # insert quests to DB
    for (keys %$quests_data) {
        delete $quests_data->{$_}->{_id};
        my $OID = $quests->collection->insert( $quests_data->{$_} ); # MongoDB::OID
        $quests_data->{$_}->{_id} = $OID->to_string;
        $quests_data->{$_}->{ts} = $OID->get_time;
    }
}

sub perl_quest_list :Test(1) {
    cmp_deeply(
        [ sort { $a->{_id} cmp $b->{_id} } @{ Play::Quests->new->list({}) } ],
        [ sort { $a->{_id} cmp $b->{_id} } values %$quests_data ],
    );
}

sub quest_list :Tests {
    my $list = http_json GET => '/api/quest';

    cmp_deeply
        [ sort { $a->{_id} cmp $b->{_id} } @$list ],
        [ sort { $a->{_id} cmp $b->{_id} } values %$quests_data ];
}

sub quest_list_filtering :Tests {
    my $list = http_json GET => '/api/quest', { params => { status => 'closed' } };

    cmp_deeply $list, [ $quests_data->{3} ];
}

sub quest_sorting :Tests {
    http_json GET => '/api/fakeuser/user_3';
    http_json POST => '/api/quest/'.$quests_data->{2}{_id}.'/like';
    http_json POST => '/api/quest/'.$quests_data->{1}{_id}.'/comment', { params => { body => 'bah!' } };

    my $list = http_json GET => '/api/quest?sort=leaderboard';
    my @names = map { $_->{name} } @$list;
    is_deeply \@names, [qw/ name_2 name_1 name_3 /];
}

sub single_quest :Tests {
    my $id          =  $quests_data->{1}->{_id};
    my $quest = http_json GET => '/api/quest/'.$id;

    cmp_deeply $quest, $quests_data->{1};
}

sub edit_quest :Tests {
    my $edited_quest = $quests_data->{1};
    my $id          = $edited_quest->{_id};
    local $edited_quest->{name} = 'name_11'; # Change

    Dancer::session login => $edited_quest->{user};

    my $put_result = http_json PUT => "/api/quest/$id", { params => { name => $edited_quest->{name} } };
    cmp_deeply $put_result, { _id => $id }, 'put result';

    my $got_quest = http_json GET => "/api/quest/$id";
    cmp_deeply $got_quest, $edited_quest;
}


sub add_quest :Tests {
    my $user = 'user_4';
    my $new_record = {
        user    => $user,
        name    => 'name_4',
        status  => 'open',
    };

    Dancer::session login => $user;

    my $add_result = http_json POST => '/api/quest', { params => $new_record };

    cmp_deeply
        $add_result,
        { %$new_record, _id => re('^\S+$'), ts => re('^\d+$') },
        'add response';

    my $id = $add_result->{_id};

    my $got_quest = http_json GET => "/api/quest/$id";
    cmp_deeply
        $got_quest,
        { %$new_record, _id => re('^\S+$'), ts => re('^\d+$') },
        'get response';
}

sub quest_events :Tests {

    my $user = 'euser';
    http_json GET => "/api/fakeuser/$user";

    my $new_record = {
        user    => $user,
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

    my @events = grep { $_->{object_type} eq 'quest' } @{ Play::Events->new->list };
    cmp_deeply \@events, [
        {
            _id => re('^\S+$'),
            ts => re('^\d+$'),
            object_type => 'quest',
            action => 'resurrect',
            author => $user,
            object_id => $quest_id,
            object => { name => 'test-quest', status => 'open', user => $user },
        },
        {
            _id => re('^\S+$'),
            ts => re('^\d+$'),
            object_type => 'quest',
            action => 'abandon',
            author => $user,
            object_id => $quest_id,
            object => { name => 'test-quest', status => 'abandoned', user => $user },
        },
        {
            _id => re('^\S+$'),
            ts => re('^\d+$'),
            object_type => 'quest',
            action => 'reopen',
            author => $user,
            object_id => $quest_id,
            object => { name => 'test-quest', status => 'open', user => $user },
        },
        {
            _id => re('^\S+$'),
            ts => re('^\d+$'),
            object_type => 'quest',
            action => 'close',
            author => $user,
            object_id => $quest_id,
            object => { name => 'test-quest', status => 'closed', user => $user },
        },
        {
            _id => re('^\S+$'),
            ts => re('^\d+$'),
            object_type => 'quest',
            action => 'add',
            author => $user,
            object_id => $quest_id,
            object => { name => 'test-quest', status => 'open', user => $user },
        },
    ];
}

sub delete_quest :Tests {
    my $id_to_remove;
    my $user;
    {
        my $list_before_resp = dancer_response GET => '/api/quest';
        my $result = decode_json($list_before_resp->content);
        is scalar @$result, 3;
        $id_to_remove = $result->[1]{_id};
        $user = $result->[1]{user};
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
    my $quest = $quests_data->{1}; # name_2, user_2

    http_json GET => "/api/fakeuser/$quest->{user}";
    Dancer::session login => $quest->{user};

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
   my $quest = $quests_data->{1};
    http_json GET => "/api/fakeuser/$quest->{user}";
    Dancer::session login => $quest->{user};

    my $user = http_json GET => '/api/current_user';
    is $user->{points}, 0, 'zero points initially';

    http_json DELETE => "/api/quest/$quest->{_id}";
    $user = http_json GET => '/api/current_user';
    is $user->{points}, 0, 'still zero points after removing an open quest';
}

sub quest_types :Tests {
    Dancer::session login => 'user_1';

    http_json POST => '/api/quest', { params => {
        name => 'typed-quest',
        type => 'blog',
    } };

    my $unknown_type_response = dancer_response POST => '/api/quest', { params => {
        name => 'typed-quest',
        type => 'nosuchtype',
    } };
    is $unknown_type_response->status, 500;
    like $unknown_type_response->content, qr/Unexpected quest type/;
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
    is $list_with_cc->[0]{comment_count}, 2;
    is $list_with_cc->[1]{comment_count}, undef;
    is $list_with_cc->[2]{comment_count}, 1;
}

sub email_like :Tests {

    http_json GET => "/api/fakeuser/foo";
    Dancer::session login => 'foo';

    register_email 'foo' => { email => 'test@example.com', notify_comments => 0, notify_likes => 1 };

    my $quest = http_json POST => '/api/quest', { params => {
        name => 'q1',
    } };

    http_json GET => "/api/fakeuser/bar";
    Dancer::session login => 'bar';

    http_json POST => "/api/quest/$quest->{_id}/like";

    my @deliveries = Email::Sender::Simple->default_transport->deliveries;
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
    Dancer::session login => 'bar2';
    http_json POST => "/api/quest/$quest->{_id}/like";

    @deliveries = Email::Sender::Simple->default_transport->deliveries;
    is scalar(@deliveries), 2, 'second email sent';
    $email = $deliveries[1];
    unlike
        $email->{email}->get_body,
        qr/Reward for completing this quest/,
        "no reward line in emails on completed quest's like";
    like
        $email->{email}->get_body,
        qr/you get one more point/,
        "'already completed' text in email";
}

__PACKAGE__->new->runtests;
