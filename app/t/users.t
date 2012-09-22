#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use Dancer;
use Play;
use Dancer::Test;
use Test::Deep qw(cmp_deeply);

use Play::Mongo qw(:test);
use JSON;
my $json = JSON->new;

{
    my $users = dancer_response GET => '/api/users';
    is $users->status, 200;
    cmp_deeply $json->decode($users->content), [];
}

done_testing;
