use t::common;

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


#--- Init
my $quests = Play::Quests->new;
my $collection = $quests->collection;
my $ids;
sub _init_db_data {

    #--- Delete all
    $collection->remove({});

    #-- Insert
    foreach ( keys %$quests_data ) {
        delete $quests_data->{$_}->{_id};
        my $OID = $collection->insert( $quests_data->{$_} ); # MongoDB::OID
        $quests_data->{$_}->{_id} = $OID->to_string;
        $ids->{ $_ } = $OID;
    }
}
_init_db_data();


subtest 'Play::Quests list' => sub {
    cmp_deeply(
        [ sort { $a->{_id} cmp $b->{_id} } @{ $quests->list({}) } ],
        [ sort { $a->{_id} cmp $b->{_id} } values %$quests_data ],
    );
};


subtest '/api/quests' => sub {

    my $response    = dancer_response GET => '/api/quests';

    is $response->{status}, 200, 'http code';

    cmp_deeply
        [ sort { $a->{_id} cmp $b->{_id} } @{ decode_json( $response->{content} ) } ],
        [ sort { $a->{_id} cmp $b->{_id} } values %$quests_data ],
        'json';
};

subtest '/api/quests filtering' => sub {

    my $response    = dancer_response GET => '/api/quests', { params => { status => 'closed' } };

    is $response->{status}, 200, 'http code';

    cmp_deeply
        decode_json( $response->{content} ),
        [ $quests_data->{3} ],
        'json';
};


subtest '/api/quest/ID' => sub {

    my $id          =  $quests_data->{1}->{_id};
    my $response    = dancer_response GET => '/api/quest/'.$id;

    cmp_deeply(
        decode_json( $response->{content} ),
        $quests_data->{1}
    );
};


subtest 'Edit specified quest' => sub {

    my $edited_quest = $quests_data->{1};
    my $id          = $edited_quest->{_id};
    local $edited_quest->{name} = 'name_11'; # Change

    #--
    my $old_login = Dancer::session->{login};
    Dancer::session login => $edited_quest->{user};

    my $response    = dancer_response PUT => '/api/quest/'.$id, { params => { name => $edited_quest->{name} } };

    #--
    my $subtestname = 'Edit specified quest, status - OK';
    my $got         = $response->{status};
    my $expect      = 200;
    is $got, $expect, $subtestname;

    #--
    $subtestname = 'Edit specified quest - OK';
    $got         = decode_json( $response->{content} );
                   delete $got->{id};
    $expect      = { result  => 'ok' };
    cmp_deeply $got, $expect, $subtestname;

    #---
    $subtestname    = 'Edit specified quest, check updated - OK';
    $got            = $collection->find_one({
                        _id => MongoDB::OID->new(value => $id)
                      });
                      Play::Quests::_prepare_quest( undef, $got );
    $expect         = $edited_quest;
    cmp_deeply $got, $expect, $subtestname;

    #-- restore session login
    Dancer::session( login => $old_login ) if $old_login;

    #--- restore data
    _init_db_data();
};


subtest 'Add new' => sub {

    my $user = 'user_4';
    my $new_record = {
        user    => $user,
        name    => 'name_4',
        status  => 'open',
    };

    #---
    my $old_login = Dancer::session->{login};
    Dancer::session login => $user;

    my $response    = dancer_response POST => '/api/quest', { params => $new_record };

    #--
    my $subtestname = 'Add new, status - OK';
    my $got         = $response->{status};
    my $expect      = 200;
    is $got, $expect, $subtestname;

    if ( ref $response->{content} eq 'GLOB' ) {
        my $fh = $response->{content};
        local $/ = undef;
        $response->{content} = [ <$fh> ];
    }

    #--
    $subtestname = 'Add new, data - OK';
    $got         = decode_json( $response->{content} );
    my $got_id = delete $got->{id};
    $expect      = { result  => 'ok' };
    cmp_deeply $got, $expect, $subtestname;

    #---
    $subtestname    = 'Add new, check inserted - OK';
    $got            = $collection->find_one( $new_record );
    Play::Quests::_prepare_quest( undef, $got );
    $new_record->{_id} = $got_id;
    $expect         = $new_record;
    cmp_deeply $got, $expect, $subtestname;

    #-- restore session login
    Dancer::session( login => $old_login ) if $old_login;

    #--- restore data
    _init_db_data();
};

subtest 'Delete' => sub {
    _init_db_data();

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
};

subtest 'Points' => sub {
    _init_db_data();

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

};

done_testing;
