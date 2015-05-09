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
        'http://localhost:8000/player/blah'
    );
}

sub quest_url :Tests {
    is(
        Play::WWW->quest_url({
            _id => '12345678901234567890abcd',
            realm => 'chaos',
            name => "doesn't matter",
        }),
        'http://localhost:8000/realm/chaos/quest/12345678901234567890abcd'
    );
}

sub frontpage :Tests {
    is(
        Play::WWW->frontpage_url(),
        'http://localhost:8000'
    );
}

sub settings :Tests {
    is(
        Play::WWW->settings_url(),
        'http://localhost:8000/settings'
    );
}

sub upic :Tests {
    is(
        Play::WWW->upic_url('foo', 'small'),
        'http://localhost:8000/api/user/foo/pic?s=small'
    );

    is(
        Play::WWW->upic_url('foo', 'normal'),
        'http://localhost:8000/api/user/foo/pic?s=normal'
    );
}

__PACKAGE__->new->runtests;
