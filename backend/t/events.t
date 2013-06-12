#!/usr/bin/perl

use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);

sub setup :Test(setup) {
    reset_db();
}

sub basic :Tests {
    db->events->add({
        type => 'a1-t1',
        author => 'foo',
        realm => 'europe',
    });
    db->events->add({
        type => 'a2-t2',
        author => 'foo',
        realm => 'europe',
    });
    db->events->add({
        type => 'a3-t3',
        author => 'foo',
        realm => 'asia',
    });

    cmp_deeply(
        db->events->list({ realm => 'europe' }),
        [
            superhashof({ type => 'a2-t2' }), # last in, first out
            superhashof({ type => 'a1-t1' }),
        ]
    );

    db->users->add({ login => 'foo', fr => ['europe'] });

    cmp_deeply(
        db->events->list({ for => 'foo' }),
        [
            superhashof({ type => 'a2-t2' }),
            superhashof({ type => 'a1-t1' }),
        ]
    );
}

sub realm_validation :Tests {
    like exception { db->events->add({ type => 'foo-bar', foo => 'bar', type => 'test' }) }, qr/not defined/;
    like exception { db->events->add({ type => 'foo-bar', foo => 'bar', type => 'test', realm => 'africa' }) }, qr/Unknown realm/;
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
            type => 'add-quest',
            quest_id => $quest->{_id},
            quest => superhashof({
                name => 'q1'
            })
        })
    ];

    db->quests->update($quest->{_id}, { name => 'q1-revised', user => 'foo' });
    $events = db->events->list({ realm => 'europe' });
    cmp_deeply $events, [
        superhashof({
            quest => superhashof({
                name => 'q1-revised'
            })
        })
    ];
}

__PACKAGE__->new->runtests;
