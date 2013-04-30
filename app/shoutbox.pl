#!/usr/bin/env perl

use strict;
use warnings;

use lib '/play/backend/lib';

use Play::DB qw(db);
use Params::Validate qw(:all);

sub main {
    my ($message) = validate_pos(@_, { type => SCALAR });

    my $users = db->users->list;

    for my $user (@$users) {
        db->notifications->add($user->{login}, 'shout', $message);
    }
}

main(join '', <>) unless caller;
