#!/usr/bin/perl

use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);

sub basic :Tests {
    db->events->add({ blah => 5, boo => 6, realm => 'first' });
    db->events->add({ foo => 'bar', realm => 'first' });
    db->events->add({ foo => 'baz', realm => 'second' });

    cmp_deeply(
        db->events->list({ realm => 'first' }),
        [
            { foo => 'bar', ts => re('^\d+$'), _id => re('^\S+$'), realm => 'first' }, # last in, first out
            { blah => 5, boo => 6, ts => re('^\d+$'), _id => re('^\S+$'), realm => 'first' },
        ]
    );
}

__PACKAGE__->new->runtests;
