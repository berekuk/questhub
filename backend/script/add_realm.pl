#!/usr/bin/env perl

use 5.012;
use warnings;

use lib '/play/backend/lib';

use Play::DB qw(db);

sub main {
    my ($id, @keepers) = @_;
    db->realms->add({
        id => $id,
        name => ucfirst($id),
        description => '',
        pic => "/i/$id.png",
        keepers => \@keepers,
    });
}

main(@ARGV) unless caller;
