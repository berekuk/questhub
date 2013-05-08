#!/usr/bin/perl

use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);

sub setup :Test(setup) {
    reset_db();
}

sub basic :Tests {
    db->events->add({ blah => 5, boo => 6, object_type => 'test', realm => 'europe' });
    db->events->add({ foo => 'bar', object_type => 'test', realm => 'europe' });
    db->events->add({ foo => 'baz', object_type => 'test', realm => 'asia' });

    cmp_deeply(
        db->events->list({ realm => 'europe' }),
        [
            { foo => 'bar', ts => re('^\d+$'), _id => re('^\S+$'), object_type => 'test', realm => 'europe' }, # last in, first out
            { blah => 5, boo => 6, ts => re('^\d+$'), _id => re('^\S+$'), object_type => 'test', realm => 'europe' },
        ]
    );
}

sub realm_validation :Tests {
    like exception { db->events->add({ foo => 'bar', object_type => 'test' }) }, qr/not defined/;
    like exception { db->events->add({ foo => 'bar', object_type => 'test', realm => 'africa' }) }, qr/Unknown realm/;
}

sub load_quests :Tests {
    db->users->add({ login => 'foo', realm => 'europe' });

    my $quest = db->quests->add({
        name => 'q1',
        user => 'foo',
        realm => 'europe',
    });

    my $events = db->events->list({ realm => 'europe' });
    cmp_deeply $events, [
        superhashof({
            object_type => 'quest',
            action => 'add',
            object => superhashof({
                name => 'q1'
            })
        })
    ];

    db->quests->update($quest->{_id}, { name => 'q1-revised', user => 'foo' });
    $events = db->events->list({ realm => 'europe' });
    cmp_deeply $events, [
        superhashof({
            object => superhashof({
                name => 'q1-revised'
            })
        })
    ];
}

__PACKAGE__->new->runtests;
