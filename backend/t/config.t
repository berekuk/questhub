#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';
use Test::More;

BEGIN {
    $ENV{PLAY_CONFIG_FILE} = 't/data/config.yml';
}

use Play::Config qw(setting);

is setting('hostport'), 'example.com:3000';
is setting('service_name'), 'example';

done_testing;
