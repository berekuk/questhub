#!/usr/bin/env perl

use strictures 1;
use strict;
use warnings;

use 5.010;

use lib '/play/backend/lib';
use Play::Mongo;

my $qc = Play::Mongo->db->get_collection('quests');
$qc->update(
    { },
    { '$unset' => { team => 1 } },
    { safe => 1, multiple => 1 }
);
