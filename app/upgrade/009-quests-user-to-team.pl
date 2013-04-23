#!/usr/bin/env perl

use strictures 1;
use strict;
use warnings;

use 5.010;

use lib '/play/backend/lib';
use Play::Mongo;

my $qc = Play::Mongo->db->get_collection('quests');

my @quests = $qc->find->all;

for my $quest (@quests) {
    my $user = delete $quest->{user};
    my @team;
    @team = ($user) if $user ne '';

    $qc->update(
        { _id => $quest->{_id} },
        { '$set' => { team => \@team } },
        { safe => 1 }
    );
}
