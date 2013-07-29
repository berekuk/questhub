#!/usr/bin/perl
use 5.012;
use warnings;

use lib 'lib';
use parent qw(Test::Class);
use Test::More;

use Play::WWW;

sub player_url :Tests {
    is(
        Play::WWW->player_url('blah'),
        'http://localhost:3000/player/blah'
    );
}

sub quest_url :Tests {
    is(
        Play::WWW->quest_url({
            _id => '12345678901234567890abcd',
            realm => 'chaos',
            name => "doesn't matter",
        }),
        'http://localhost:3000/realm/chaos/quest/12345678901234567890abcd'
    );
}

sub frontpage :Tests {
    is(
        Play::WWW->frontpage_url(),
        'http://localhost:3000'
    );
}

__PACKAGE__->new->runtests;
