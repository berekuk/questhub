use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);

sub setup :Test(setup) {
    reset_db();
}

sub add :Tests {
    db->users->add({ login => $_, realms => ['europe'] }) for qw( foo );
    my $quest = db->quests->add({
        name => 'quest name',
        team => ['foo'],
        status => 'open',
        realm => 'europe',
        description => "Blah\n\nBlah.",
    });
    cmp_deeply $quest, superhashof({
        _id => re('^\w+$'),
        ts => re('^\d+$'),
        name => 'quest name',
        status => 'open',
        team => ['foo'],
        realm => 'europe',
        description => "Blah\n\nBlah.",
    });

    # no description, no status
    $quest = db->quests->add({
        name => 'quest name 2',
        team => ['foo'],
        realm => 'europe',
    });
    cmp_deeply $quest, superhashof({
        _id => re('^\w+$'),
        ts => re('^\d+$'),
        name => 'quest name 2',
        status => 'open',
        team => ['foo'],
        realm => 'europe',
    });
}

sub add_check_user :Tests {
    like exception {
        db->quests->add({
            name => 'quest name',
            team => ['foo'],
            status => 'open',
            realm => 'europe',
        });
    }, qr/User .* not found/;

    db->users->add({ login => 'foo', realms => ['asia'] });

    is exception {
        db->quests->add({
            name => 'quest name',
            team => ['foo'],
            status => 'open',
            realm => 'europe',
        });
    }, undef;
    my $user = db->users->get_by_login('foo');
    cmp_deeply $user->{realms}, ['asia', 'europe'];

    is exception {
        db->quests->add({
            name => 'quest name',
            team => ['foo'],
            status => 'open',
            realm => 'asia',
        });
    }, undef;
    $user = db->users->get_by_login('foo');
    cmp_deeply $user->{realms}, ['asia', 'europe'];
}

sub leave_join :Tests {
    db->users->add({ login => $_, realms => ['europe'] }) for qw( foo bar baz );
    my $quest = db->quests->add({
        name => 'quest name',
        team => ['foo'],
        status => 'open',
        realm => 'europe',
    });

    like exception { db->quests->leave($quest->{_id}, 'bar') }, qr/unable to leave/, "can't leave the quest you're not in";
    is exception { db->quests->leave($quest->{_id}, 'foo') }, undef, 'leaving quest with an empty team';

    $quest = db->quests->get($quest->{_id});
    cmp_deeply $quest->{team}, [];

    is exception { db->quests->join($quest->{_id}, 'foo') }, undef, "joining unclaimed quest doesn't require an invite";
    $quest = db->quests->get($quest->{_id});
    cmp_deeply $quest->{team}, ['foo'];

    like exception { db->quests->join($quest->{_id}, 'bar') }, qr/unable to join/, "can't join unless you're invited";
    ok exception { db->quests->invite($quest->{_id}, 'foo', 'foo') }, "foo can't invite himself";
    ok exception { db->quests->invite($quest->{_id}, 'bar', 'bar') }, "bar can't invite himself";
    ok exception { db->quests->invite($quest->{_id}, 'bar', 'baz') }, "baz can't invite himself";
    $quest = db->quests->get($quest->{_id});
    cmp_deeply $quest->{invitee}, undef;

    db->quests->invite($quest->{_id}, 'bar', 'foo');
    db->quests->invite($quest->{_id}, 'baz', 'foo');
    $quest = db->quests->get($quest->{_id});
    cmp_deeply $quest->{team}, ['foo'];
    cmp_deeply $quest->{invitee}, ['bar', 'baz'];

    db->quests->uninvite($quest->{_id}, 'baz', 'foo');
    $quest = db->quests->get($quest->{_id});
    cmp_deeply $quest->{invitee}, ['bar'];

    is exception { db->quests->join($quest->{_id}, 'bar') }, undef, 'joining after invitation';
    $quest = db->quests->get($quest->{_id});
    cmp_deeply $quest->{team}, ['foo', 'bar'];

    like exception { db->quests->invite($quest->{_id}, 'blah', 'foo') }, qr/Invitee .*not found/;
}

sub invite_non_open :Tests {
    db->users->add({ login => $_, realms => ['europe'] }) for qw( foo bar );
    my $quest = db->quests->add({
        name => 'quest name',
        team => ['foo'],
        status => 'open',
        realm => 'europe',
    });
    db->quests->update($quest->{_id}, { status => 'closed', user => 'foo' });

    ok exception { db->quests->invite($quest->{_id}, 'bar', 'foo') }, "can't invite to non-open quest";
}

sub join_non_open :Tests {
    db->users->add({ login => $_, realms => ['europe'] }) for qw( foo bar );
    my $quest = db->quests->add({
        name => 'quest name',
        team => ['foo'],
        status => 'open',
        realm => 'europe',
    });
    db->quests->invite($quest->{_id}, 'bar', 'foo');
    db->quests->update($quest->{_id}, { status => 'closed', user => 'foo' });

    ok exception { db->quests->join($quest->{_id}, 'bar') }, "can't join - quest is closed";
    is db->quests->get($quest->{_id})->{invitee}, undef, 'invitee list is cleared on quest completion';
}

sub list :Tests {
    db->users->add({ login => 'foo', realms => ['europe'] });
    my @data = (
        {
            name => 'q1',
            team => ['foo'],
            status => 'open',
            realm => 'europe',
        },
        {
            name => 'q2',
            team => ['foo'],
            status => 'open',
            realm => 'europe',
        },
        {
            name => 'q3',
            team => ['foo'],
            status => 'open',
            realm => 'europe',
        },
        {
            name => 'q4',
            team => ['foo'],
            status => 'open',
            realm => 'asia',
        },
    );
    for (@data) {
        $_->{_id} = db->quests->add($_)->{_id};
    }

    cmp_deeply
        db->quests->list({ realm => 'europe' }),
        [ reverse map { superhashof($_) } @data[0..2] ];

    cmp_deeply
        db->quests->list({}),
        [ reverse map { superhashof($_) } @data ];

    cmp_deeply
        db->quests->list({ order => 'desc', realm => 'europe' }),
        [ reverse map { superhashof($_) } @data[0..2] ];

    cmp_deeply
        db->quests->list({ order => 'asc', realm => 'europe' }),
        [ map { superhashof($_) } @data[0..2] ];
}

sub list_leaderboard :Tests {
    db->users->add({ login => $_, realms => ['europe'] }) for qw( foo l1 l2 l3 );
    my @data = (
        {
            name => 'q1',
            team => ['foo'],
            status => 'open',
            realm => 'europe',
        },
        {
            name => 'q2',
            team => ['foo'],
            status => 'open',
            realm => 'europe',
        },
        {
            name => 'q3',
            team => ['foo'],
            status => 'open',
            realm => 'europe',
        },
    );
    for (@data) {
        $_->{_id} = db->quests->add($_)->{_id};
    }
    db->quests->like($data[0]->{_id}, 'l1');
    db->quests->like($data[2]->{_id}, 'l1');
    db->quests->like($data[2]->{_id}, 'l2');

    cmp_deeply
        db->quests->list({ sort => 'leaderboard', realm => 'europe' }),
        [ map { superhashof($_) } @data[2,0,1] ];
}

sub list_unclaimed :Tests {
    db->users->add({ login => $_, realms => ['europe'] }) for qw( foo );
    my @data = (
        map {
            {
                name => "q$_",
                team => ['foo'],
                status => 'open',
                realm => 'europe',
            }
        } 1..3
    );
    for (@data) {
        $_->{_id} = db->quests->add($_)->{_id};
    }
    db->quests->leave($data[1]->{_id}, 'foo');
    db->quests->leave($data[2]->{_id}, 'foo');
    $data[1]->{team} = [];
    $data[2]->{team} = [];

    cmp_deeply
        db->quests->list({ realm => 'europe' }),
        [ reverse map { superhashof($_) } @data ];

    cmp_deeply
        db->quests->list({ unclaimed => 1, realm => 'europe' }),
        [ reverse map { superhashof($_) } @data[1,2] ];
}

sub watch_unwatch :Tests {
    db->users->add({ login => $_, realms => ['europe'] }) for qw( foo );
    my $quest = db->quests->add({
        name => 'quest name',
        team => ['foo'],
        status => 'open',
        realm => 'europe',
    });

    like exception { db->quests->watch($quest->{_id}, 'foo') }, qr/unable to watch/;
    like exception { db->quests->unwatch($quest->{_id}, 'foo') }, qr/unable to unwatch/;

    db->quests->watch($quest->{_id}, 'bar');
    db->quests->watch($quest->{_id}, 'baz');
    $quest = db->quests->get($quest->{_id});
    cmp_deeply $quest->{watchers}, [qw( bar baz )];

    db->quests->unwatch($quest->{_id}, 'bar');
    $quest = db->quests->get($quest->{_id});
    cmp_deeply $quest->{watchers}, [qw( baz )];
}

sub list_watched :Tests {
    db->users->add({ login => $_, realms => ['europe'] }) for qw( foo );

    my @quests = map {
        db->quests->add({
            name => "q$_",
            team => ['foo'],
            status => 'open',
            realm => 'europe',
        })
    } (1 .. 5);

    db->quests->watch($quests[1]->{_id}, 'irrelevant');
    db->quests->watch($quests[2]->{_id}, 'bar');
    db->quests->watch($quests[2]->{_id}, 'baz');
    db->quests->watch($quests[3]->{_id}, 'baz');

    is_deeply
        [ map { $_->{_id} } sort { $a->{_id} cmp $b->{_id} } @{ db->quests->list({ watchers => 'baz', realm => 'europe' }) } ],
        [ $quests[2]->{_id}, $quests[3]->{_id} ]
    ;
}

sub list_realm :Tests {
    db->users->add({ login => $_, realms => ['europe', 'asia'] }) for qw( foo );

    my @europe_quests = map {
        db->quests->add({
            name => "e$_",
            team => ['foo'],
            status => 'open',
            realm => 'europe',
        })
    } (1 .. 3);
    my @asia_quests = map {
        db->quests->add({
            name => "a$_",
            team => ['foo'],
            status => 'open',
            realm => 'asia',
        })
    } (1 .. 4);

    is_deeply
        [ map { $_->{_id} } sort { $a->{_id} cmp $b->{_id} } @{ db->quests->list({ realm => 'europe' }) } ],
        [ map { $_->{_id} } @europe_quests ]
    ;

    is_deeply
        [ map { $_->{_id} } sort { $a->{_id} cmp $b->{_id} } @{ db->quests->list({ realm => 'asia' }) } ],
        [ map { $_->{_id} } @asia_quests ]
    ;
}

sub remove :Tests {
    db->users->add({ login => $_, realms => ['europe'] }) for qw( foo foo2 );
    my @quests = map {
        db->quests->add({
            name => "q$_",
            team => ['foo'],
            status => 'open',
            realm => 'europe',
        })
    } (1 .. 3);
    for (@quests) {
        db->quests->invite($_->{_id}, 'foo2', 'foo');
        db->quests->join($_->{_id}, 'foo2');
    }

    like exception { db->quests->remove($quests[2]->{_id}, {}) }, qr/type constraint/;
    like exception { db->quests->remove($quests[2]->{_id}, { user => 'bar' }) }, qr/access denied/;
    is exception { db->quests->remove($quests[2]->{_id}, { user => 'foo' }) }, undef;

    is scalar @{ db->quests->list({ realm => 'europe' }) }, 2;

    is_deeply
        [ sort map { $_->{name} } @{ db->quests->list({ realm => 'europe' }) } ],
        ['q1', 'q2'];

    like exception { db->quests->get($quests[2]->{_id}) }, qr/is deleted/;

    # any team member can remove a quest
    is exception { db->quests->remove($quests[1]->{_id}, { user => 'foo2' }) }, undef;
    is_deeply
        [sort map { $_->{name} } @{ db->quests->list({ realm => 'europe' }) }],
        ['q1'];
}

sub update :Tests {
    db->users->add({ login => 'foo', realms => ['europe'] });

    my $quest = db->quests->add({
        name => 'q1',
        user => 'foo',
        status => 'open',
        realm => 'europe',
    });

    db->quests->update($quest->{_id}, {
        name => 'q2',
        tags => ['t1'],
        user => 'foo',
        realm => 'europe',
    });

    $quest = db->quests->get($quest->{_id});
    cmp_deeply $quest, superhashof({
        team => ['foo'],
        name => 'q2',
        status => 'open',
        tags => ['t1'],
        realm => 'europe',
    });
}

sub scoring :Tests {
    db->users->add({ login => $_, realms => ['europe'] }) for qw( foo bar baz );

    my $quest = db->quests->add({
        name => 'q1',
        user => 'foo',
        status => 'open',
        realm => 'europe',
    });
    db->quests->like($quest->{_id}, 'baz');
    db->quests->invite($quest->{_id}, 'bar', 'foo');
    db->quests->join($quest->{_id}, 'bar');

    db->quests->update($quest->{_id}, { status => 'closed', user => 'foo' });

    is db->users->get_by_login('foo')->{rp}{europe}, 2;
    is db->users->get_by_login('bar')->{rp}{europe}, 2;
    is db->users->get_by_login('baz')->{rp}{europe}, 0;
}

sub bulk_get :Tests {
    db->users->add({ login => $_, realms => ['europe'] }) for qw( foo );

    my @quests = map {
        db->quests->add({
            name => "q$_",
            user => 'foo',
            status => 'open',
            realm => 'europe',
        })
    } 1..5;

    my $bulk_get_result = db->quests->bulk_get([ map { $quests[$_]{_id} } qw( 0 2 3 ) ]);
    cmp_deeply $bulk_get_result, {
        map { $quests[$_]{_id} => $quests[$_] } qw( 0 2 3 )
    };

    db->quests->remove($quests[2]{_id}, { user => 'foo' });
    $bulk_get_result = db->quests->bulk_get([ map { $quests[$_]{_id} } qw( 0 2 3 ) ]);
    cmp_deeply $bulk_get_result, {
        map { $quests[$_]{_id} => $quests[$_] } qw( 0 3 )
    }, 'removed quest is unobtainable via bulk_get';
}

sub move_to_realm :Tests {
    db->users->add({ login => $_, realms => ['europe'] }) for qw( foo bar );

    my @quests = map {
        db->quests->add({
            name => "q$_",
            user => 'foo',
            realm => 'europe',
        })
    } 1..5;

    like exception {
        db->quests->move_to_realm($quests[0]{_id}, 'asia', 'bar')
    }, qr/Access denied/, "wrong user can't move";

    is db->quests->get($quests[0]{_id})->{realm}, 'europe', 'realm not changed after access denied';

    db->quests->move_to_realm($quests[0]{_id}, 'asia', 'foo');
    is db->quests->get($quests[0]{_id})->{realm}, 'asia', 'realm changed';

    cmp_deeply db->users->get_by_login('foo')->{realms}, ['europe', 'asia'], 'user joins the realm if quest is moved';

    db->quests->update($quests[1]{_id}, { status => 'closed', user => 'foo' });
    db->quests->update($quests[2]{_id}, { status => 'closed', user => 'foo' });
    cmp_deeply
        db->users->get_by_login('foo')->{rp},
        { europe => 2, asia => 0 };

    db->quests->move_to_realm($quests[1]{_id}, 'asia', 'foo');
    cmp_deeply
        db->users->get_by_login('foo')->{rp},
        { europe => 1, asia => 1 };

    db->quests->move_to_realm($quests[1]{_id}, 'europe', 'foo');
    cmp_deeply
        db->users->get_by_login('foo')->{rp},
        { europe => 2, asia => 0 };
}

__PACKAGE__->new->runtests;
