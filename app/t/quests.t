use t::common;
use parent qw(Test::Class);

use Play::Quests;

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
    $quests->collection->remove({});

    # insert quests to DB
    for (keys %$quests_data) {
        delete $quests_data->{$_}->{_id};
        my $OID = $quests->collection->insert( $quests_data->{$_} ); # MongoDB::OID
        $quests_data->{$_}->{_id} = $OID->to_string;
    }
}

sub perl_quest_list :Test(1) {
    cmp_deeply(
        [ sort { $a->{_id} cmp $b->{_id} } @{ Play::Quests->new->list({}) } ],
        [ sort { $a->{_id} cmp $b->{_id} } values %$quests_data ],
    );
}

sub quest_list :Tests {
    my $list = http_json GET => '/api/quests';

    cmp_deeply
        [ sort { $a->{_id} cmp $b->{_id} } @$list ],
        [ sort { $a->{_id} cmp $b->{_id} } values %$quests_data ];
}

sub quest_list_filtering :Tests {
    my $list = http_json GET => '/api/quests', { params => { status => 'closed' } };

    cmp_deeply $list, [ $quests_data->{3} ];
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
    cmp_deeply $put_result, { result => 'ok', id => $id }, 'put result';

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
        { result => 'ok', id => re('^\S+$') },
        'response';

    my $id = $add_result->{id};

    my $got_quest = http_json GET => "/api/quest/$id";
    delete $got_quest->{_id};
    cmp_deeply $got_quest, $new_record;
}

sub delete_quest :Tests {
    my $id_to_remove;
    my $user;
    {
        my $list_before_resp = dancer_response GET => '/api/quests';
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
        my $delete_resp = dancer_response DELETE => "/api/quest/$id_to_remove";
        is $delete_resp->status, 500, "Can't delete another user's quest";
    }

    {
        Dancer::session login => $user;
        my $delete_resp = dancer_response DELETE => "/api/quest/$id_to_remove";
        is $delete_resp->status, 200, "Can delete the quest you own" or diag $delete_resp->content;
    }

    {
        my $list_after_resp = dancer_response GET => '/api/quests';
        is scalar @{ decode_json($list_after_resp->content) }, 2, 'deleted quests are not shown in list';
    }
}

sub points :Tests {
    my $quest = $quests_data->{1};

    http_json GET => "/api/fakeuser/$quest->{user}";
    Dancer::session login => $quest->{user};

    my $user = http_json GET => '/api/user';
    is $user->{points} || 0, 0;

    http_json PUT => "/api/quest/$quest->{_id}", { params => { status => 'closed' } };

    $user = http_json GET => '/api/user';
    is $user->{points}, 1;
}

__PACKAGE__->new->runtests;
