#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use Dancer;
use Play;
use Dancer::Test;

# not logged in
{
    response_status_is [GET => '/api/quests'], 200, '/api/quests is public';
}

done_testing;
