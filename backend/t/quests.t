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
        user => 'foo',
        team => ['foo'],
    });
}

sub leave_join :Tests {
    my $quest = db->quests->add({
        name => 'quest name',
        team => ['foo'],
        status => 'open',
    });

    like exception { db->quests->leave($quest->{_id}, '') }, qr/only non-empty users can/;
    like exception { db->quests->leave($quest->{_id}, 'bar') }, qr/unable to leave/;
    is exception { db->quests->leave($quest->{_id}, 'foo') }, undef;

    $quest = db->quests->get($quest->{_id});
    cmp_deeply $quest->{team}, [];

    db->quests->join($quest->{_id}, 'foo');
}

sub join_team :Tests {
    local $TODO = 'team quests not implemented';

    my $quest = db->quests->add({
        name => 'quest name',
        team => ['foo'],
        status => 'open',
    });

    is exception { db->quests->join($quest->{_id}, 'bar') }, undef;
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

__PACKAGE__->new->runtests;
