use t::common;
use parent qw(Test::Class);

use JSON qw(encode_json decode_json);

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

    Dancer::session login => undef;
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
    my $response    = dancer_response GET => '/api/quests';
    is $response->{status}, 200, 'http code';

    cmp_deeply
        [ sort { $a->{_id} cmp $b->{_id} } @{ decode_json( $response->{content} ) } ],
        [ sort { $a->{_id} cmp $b->{_id} } values %$quests_data ],
        'json';
}

sub quest_list_filtering :Tests {
    my $response    = dancer_response GET => '/api/quests', { params => { status => 'closed' } };

    is $response->{status}, 200, 'http code';

    cmp_deeply
        decode_json( $response->{content} ),
        [ $quests_data->{3} ],
        'json';
}

sub single_quest :Tests {
    my $id          =  $quests_data->{1}->{_id};
    my $response    = dancer_response GET => '/api/quest/'.$id;

    cmp_deeply(
        decode_json( $response->{content} ),
        $quests_data->{1}
    );
}

sub edit_quest :Tests {
    my $edited_quest = $quests_data->{1};
    my $id          = $edited_quest->{_id};
    local $edited_quest->{name} = 'name_11'; # Change

    Dancer::session login => $edited_quest->{user};

    my $response = dancer_response PUT => "/api/quest/$id", { params => { name => $edited_quest->{name} } };
    is $response->status, 200, 'status - OK';

    cmp_deeply decode_json($response->content), { result => 'ok', id => $id }, 'json';

    my $get_response = dancer_response GET => "/api/quest/$id";
    is $get_response->status, 200;
    cmp_deeply decode_json($get_response->content), $edited_quest;
}


sub add_quest :Tests {
    my $user = 'user_4';
    my $new_record = {
        user    => $user,
        name    => 'name_4',
        status  => 'open',
    };

    Dancer::session login => $user;

    my $response    = dancer_response POST => '/api/quest', { params => $new_record };

    is $response->status, 200, 'status code';

    if (ref $response->content eq 'GLOB') {
        my $fh = $response->content;
        local $/ = undef;
        $response->content(join '', <$fh>);
    }

    cmp_deeply
        decode_json($response->content),
        { result => 'ok', id => re('^\S+$') },
        'response';

    my $id = decode_json($response->content)->{id};

    my $get_response = dancer_response GET => "/api/quest/$id";
    is $get_response->status, 200;
    my $got_quest = decode_json($get_response->content);
    delete $got_quest->{_id};
    cmp_deeply $got_quest, $new_record;
}

sub delete_quest :Tests {
    my $id_to_remove;
    my $user;
    {
        my $list_before_resp = dancer_response GET => '/api/quests';
        my $result = decode_json($list_before_resp->{content});
        is scalar @$result, 3;
        $id_to_remove = $result->[1]{_id};
        $user = $result->[1]{user};
        like $id_to_remove, qr/^[0-9a-f]{24}$/; # just an assertion
    }

    {
        my $delete_resp = dancer_response DELETE => "/api/quest/$id_to_remove";
        is $delete_resp->{status}, 500, "Can't delete a quest while not logged in";
    }

    {
        Dancer::session login => 'blah';
        my $delete_resp = dancer_response DELETE => "/api/quest/$id_to_remove";
        is $delete_resp->{status}, 500, "Can't delete another user's quest";
    }

    {
        Dancer::session login => $user;
        my $delete_resp = dancer_response DELETE => "/api/quest/$id_to_remove";
        is $delete_resp->{status}, 200, "Can delete the quest you own" or diag $delete_resp->{content};
    }

    {
        my $list_after_resp = dancer_response GET => '/api/quests';
        is scalar @{ decode_json($list_after_resp->{content}) }, 2, 'deleted quests are not shown in list';
    }
}

sub points :Tests {
    my $quest = $quests_data->{1};

    my $add_user_result = dancer_response GET => "/api/fakeuser/$quest->{user}";
    is $add_user_result->status, 200 or diag $add_user_result->content;
    Dancer::session login => $quest->{user};

    my $user_response = dancer_response GET => '/api/user';
    is decode_json($user_response->content)->{points} || 0, 0;

    my $response = dancer_response PUT => "/api/quest/$quest->{_id}", { params => { status => 'closed' } };
    is $response->status, 200, 'updating status is ok' or diag $response->{content};

    $user_response = dancer_response GET => '/api/user';
    is decode_json($user_response->content)->{points}, 1;
}

__PACKAGE__->new->runtests;
