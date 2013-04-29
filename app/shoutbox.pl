#!/usr/bin/env perl

use 5.012;
use warnings;

use lib '/play/app/lib';

use Play::DB qw(db);

use Type::Params qw(validate);
use Types::Standard qw(Str);

sub main {
    my ($message) = validate(\@_, Str);

    my $users = db->users->list;

    for my $user (@$users) {
        db->notifications->add($user->{login}, 'shout', $message);
    }
}

main(join '', <>) unless caller;
