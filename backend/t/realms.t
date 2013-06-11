#!/usr/bin/perl
use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);
use Test::Fatal;

sub validate_name :Tests {
    ok not exception { db->realms->validate_name('europe') };
    ok exception { db->realms->validate_name('blah') };
}

__PACKAGE__->new->runtests;
