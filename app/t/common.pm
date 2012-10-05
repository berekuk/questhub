package t::common;

use strict;
use warnings;

use lib 'lib';
use Import::Into;

use Play::Mongo qw(:test);

sub import {
    my $target = caller;

    require Test::More; Test::More->import::into($target, import => ['!pass']);
    require Test::Deep; Test::Deep->import::into($target, qw(cmp_deeply re));

    # the order is important
    require Dancer; Dancer->import::into($target);
    require Play; Play->import::into($target);
    require Dancer::Test; Dancer::Test->import::into($target);
}

1;
