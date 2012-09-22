#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use Play::Mongo qw(:test);

use Dancer;
use Play;
use Dancer::Test;
use Test::Deep qw(cmp_deeply re);

use JSON;
my $json = JSON->new;

{
    my $users = dancer_response GET => '/api/users';
    is $users->status, 200;
    cmp_deeply $json->decode($users->content), [];
}

{
    my $add_result = dancer_response GET => '/api/fakeuser/blah';
    is $add_result->status, 200;
}

{
    my $user = dancer_response GET => '/api/user';
    is $user->status, 200;
    cmp_deeply $json->decode($user->content), {
        "twitter" => {
            "login" => 'blah',
        },
        "_id" => re('\S+'),
        "login" => 'blah',
    };
}

done_testing;
