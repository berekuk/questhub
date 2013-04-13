#!/usr/bin/perl

use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);

sub basic :Tests {
    db->events->add({ blah => 5, boo => 6 });
    db->events->add({ foo => 'bar' });

    cmp_deeply(
        db->events->list,
        [
            { foo => 'bar', ts => re('^\d+$'), _id => re('^\S+$') }, # last in, first out
            { blah => 5, boo => 6, ts => re('^\d+$'), _id => re('^\S+$') },
        ]
    );
}

__PACKAGE__->new->runtests;
