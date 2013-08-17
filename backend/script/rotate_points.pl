#!/usr/bin/env perl
package script::rotate_points;

use 5.012;
use warnings;
use lib '/play/backend/lib';

use Play::DB qw(db);

sub main {
    my $total = db->users->rotate_points;
    say "$total rotated";
}

main(@ARGV) unless caller;
