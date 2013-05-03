#!/usr/bin/perl

use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);

sub basic :Tests {
    db->events->add({ blah => 5, boo => 6, realm => 'europe' });
    db->events->add({ foo => 'bar', realm => 'europe' });
    db->events->add({ foo => 'baz', realm => 'asia' });

    cmp_deeply(
        db->events->list({ realm => 'europe' }),
        [
            { foo => 'bar', ts => re('^\d+$'), _id => re('^\S+$'), realm => 'europe' }, # last in, first out
            { blah => 5, boo => 6, ts => re('^\d+$'), _id => re('^\S+$'), realm => 'europe' },
        ]
    );
}

sub realm_validation :Tests {
    like exception { db->events->add({ foo => 'bar' }) }, qr/not defined/;
    like exception { db->events->add({ foo => 'bar', realm => 'africa' }) }, qr/Unknown realm/;

}

__PACKAGE__->new->runtests;
