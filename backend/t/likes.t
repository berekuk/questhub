#!/usr/bin/perl


use lib 'lib';
use Play::Test;
use Play::DB qw(db);

use parent qw(Test::Class);
use Test::Fatal;

sub setup :Tests(setup) {
    db->users->collection->remove({});
}

sub like_quest :Tests {
    db->users->add({ login => $_ }) for qw( blah user1 user2 );

    my $quest = db->quests->add({
        team => ['blah'],
        name => 'foo, foo',
        status => 'open',
    });
    my $id = $quest->{_id};
    db->quests->update($id, { status => 'closed', user => 'blah' });

    db->quests->like($id, 'user1');
    db->quests->like($id, 'user2');

    # double like is forbidden
    ok exception { db->quests->like($id, 'user2') };

    cmp_deeply
        db->quests->get($id),
        {
            _id => re('^\S+$'),
            ts => re('^\d+$'),
            likes => [
                'user1', 'user2'
            ],
            name => 'foo, foo',
            status => 'closed',
            user => 'blah',
            team => ['blah'],
            author => 'blah',
        };

    is db->users->get_by_login('blah')->{points}, 3;
}

sub self_like_quest :Tests {
    db->users->add({ login => $_ }) for qw( blah );

    my $quest = db->quests->add({
        team => ['blah'],
        name => 'foo, foo',
        status => 'open',
    });
    my $id = $quest->{_id};

    like exception { db->quests->like($id, 'blah') }, qr/unable to like your own quest/;
}

__PACKAGE__->new->runtests;
