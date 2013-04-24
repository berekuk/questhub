use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);

sub setup :Test(setup) {
    reset_db();
}

sub add :Tests {
    my $quest = db->quests->add({
        name => 'quest name',
        team => ['foo'],
        status => 'open',
    });
    cmp_deeply $quest, superhashof({
        _id => re('^\w+$'),
        ts => re('^\d+$'),
        name => 'quest name',
        status => 'open',
        team => ['foo'],
    });
}

sub leave_join :Tests {
    db->users->add({ login => $_ }) for qw( foo bar baz );
    my $quest = db->quests->add({
        name => 'quest name',
        team => ['foo'],
        status => 'open',
    });

    like exception { db->quests->leave($quest->{_id}, 'bar') }, qr/unable to leave/, "can't leave the quest you're not in";
    is exception { db->quests->leave($quest->{_id}, 'foo') }, undef, 'leaving quest with an empty team';

    $quest = db->quests->get($quest->{_id});
    cmp_deeply $quest->{team}, [];

    is exception { db->quests->join($quest->{_id}, 'foo') }, undef, "joining unclaimed quest doesn't require an invite";
    $quest = db->quests->get($quest->{_id});
    cmp_deeply $quest->{team}, ['foo'];

    like exception { db->quests->join($quest->{_id}, 'bar') }, qr/unable to join/, "can't join unless you're invited";
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
}

sub list :Tests {
    my @data = (
        {
            name => 'q1',
            team => ['foo'],
            status => 'open',
        },
        {
            name => 'q2',
            team => ['foo'],
            status => 'open',
        },
        {
            name => 'q3',
            team => ['foo'],
            status => 'open',
        },
    );
    for (@data) {
        $_->{_id} = db->quests->add($_)->{_id};
    }

    cmp_deeply
        db->quests->list({}),
        [ reverse map { superhashof($_) } @data ];

    cmp_deeply
        db->quests->list({ order => 'desc' }),
        [ reverse map { superhashof($_) } @data ];

    cmp_deeply
        db->quests->list({ order => 'asc' }),
        [ map { superhashof($_) } @data ];
}

sub list_leaderboard :Tests {
    db->users->add({ login => $_ }) for qw( foo l1 l2 l3 );
    my @data = (
        {
            name => 'q1',
            team => ['foo'],
            status => 'open',
        },
        {
            name => 'q2',
            team => ['foo'],
            status => 'open',
        },
        {
            name => 'q3',
            team => ['foo'],
            status => 'open',
        },
    );
    for (@data) {
        $_->{_id} = db->quests->add($_)->{_id};
    }
    db->quests->like($data[0]->{_id}, 'l1');
    db->quests->like($data[2]->{_id}, 'l1');
    db->quests->like($data[2]->{_id}, 'l2');

    cmp_deeply
        db->quests->list({ sort => 'leaderboard' }),
        [ map { superhashof($_) } @data[2,0,1] ];
}

sub list_unclaimed :Tests {
    my @data = (
        {
            name => 'q1',
            team => ['foo'],
            status => 'open',
        },
        {
            name => 'q2',
            team => ['foo'],
            status => 'open',
        },
        {
            name => 'q3',
            team => ['foo'],
            status => 'open',
        },
    );
    for (@data) {
        $_->{_id} = db->quests->add($_)->{_id};
    }
    db->quests->leave($data[1]->{_id}, 'foo');
    db->quests->leave($data[2]->{_id}, 'foo');
    $data[1]->{team} = [];
    $data[2]->{team} = [];

    cmp_deeply
        db->quests->list({}),
        [ reverse map { superhashof($_) } @data ];

    cmp_deeply
        db->quests->list({ unclaimed => 1 }),
        [ reverse map { superhashof($_) } @data[1,2] ];
}

sub watch_unwatch :Tests {
    my $quest = db->quests->add({
        name => 'quest name',
        team => ['foo'],
        status => 'open',
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

    my @quests = map {
        db->quests->add({
            name => "q$_",
            team => ['foo'],
            status => 'open',
        })
    } (1 .. 5);

    db->quests->watch($quests[1]->{_id}, 'irrelevant');
    db->quests->watch($quests[2]->{_id}, 'bar');
    db->quests->watch($quests[2]->{_id}, 'baz');
    db->quests->watch($quests[3]->{_id}, 'baz');

    is_deeply
        [ map { $_->{_id} } sort { $a->{_id} cmp $b->{_id} } @{ db->quests->list({ watchers => 'baz' }) } ],
        [ $quests[2]->{_id}, $quests[3]->{_id} ]
    ;
}

sub remove :Tests {
    my @quests = map {
        db->quests->add({
            name => "q$_",
            team => ['foo'],
            status => 'open',
        })
    } (1 .. 3);
    for (@quests) {
        db->quests->invite($_->{_id}, 'foo2', 'foo');
        db->quests->join($_->{_id}, 'foo2');
    }

    like exception { db->quests->remove($quests[2]->{_id}, {}) }, qr/no user/;
    like exception { db->quests->remove($quests[2]->{_id}, { user => 'bar' }) }, qr/access denied/;
    is exception { db->quests->remove($quests[2]->{_id}, { user => 'foo' }) }, undef;

    is scalar @{ db->quests->list }, 2;
    is_deeply [sort map { $_->{name} } @{ db->quests->list }], ['q1', 'q2'];
    like exception { db->quests->get($quests[2]->{_id}) }, qr/is deleted/;

    # any team member can remove a quest
    is exception { db->quests->remove($quests[1]->{_id}, { user => 'foo2' }) }, undef;
    is_deeply [sort map { $_->{name} } @{ db->quests->list }], ['q1'];
}

__PACKAGE__->new->runtests;
