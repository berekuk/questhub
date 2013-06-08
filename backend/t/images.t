#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';
use parent qw(Test::Class);
use Test::More;
use Test::Deep qw(cmp_deeply ignore);

use Scalar::Util qw(blessed);

use Play::DB qw(db);

sub object :Tests {
    ok(
        blessed(db->images),
        'images is an object'
    );
}

sub upic :Tests {
    cmp_deeply(
        db->images->upic_default(),
        { small => ignore, normal => ignore }
    );

    cmp_deeply(
        db->images->upic_by_email('foo@example.com'),
        { small => ignore, normal => ignore }
    );

    cmp_deeply(
        db->images->upic_by_twitter_login('berekuk'),
        { small => ignore, normal => ignore }
    );
}

__PACKAGE__->new->runtests;
