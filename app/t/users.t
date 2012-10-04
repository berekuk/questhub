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
    for my $user (qw( blah blah2 )) {
        my $add_result = dancer_response GET => "/api/fakeuser/$user";
        is $add_result->status, 200;
    }
}

{
    my $user = dancer_response GET => '/api/user';
    is $user->status, 200;
    cmp_deeply $json->decode($user->content), {
        "twitter" => {
            "login" => 'blah2',
        },
        "_id" => re('\S+'),
        "login" => 'blah2',
    };
}

{
    my $user = dancer_response GET => '/api/users';
    is $user->status, 200;
    cmp_deeply $json->decode($user->content), [
        {
            "twitter" => {
                "login" => 'blah',
            },
            "_id" => re('\S+'),
            "login" => 'blah',
        },
        {
            "twitter" => {
                "login" => 'blah2',
            },
            "_id" => re('\S+'),
            "login" => 'blah2',
        },
    ];
}

{
    my $users = dancer_response GET => '/api/logout';
    is $users->status, 200;

    my $user = dancer_response GET => '/api/user';
    is $user->status, 200;
    cmp_deeply $json->decode($user->content), { error => 'not authorized' };
}

done_testing;
