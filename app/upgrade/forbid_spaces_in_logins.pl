#!/usr/bin/env perl

use strict;
use warnings;

use 5.010;

use Play::Mongo;

my @users = Play::Mongo->db->get_collection('users')->find()->all();
my @bad_logins = grep { $_ !~ '^\w+$' } map { $_->{login} } @users;

for my $login (@bad_logins) {
    my $new_login = $login;
    $new_login =~ s/\W/_/g;
    $new_login =~ s/_+/_/g;
    say "$login => $new_login";

    for my $pair (
        [comments => 'author'],
        [quests => 'user'],
        [user_settings => 'user'],
        [users => 'login'],
    ) {
        my ($collection, $field) = @$pair;
        Play::Mongo->db->get_collection($collection)->update(
            { $field => $login },
            { '$set' => { $field => $new_login } },
            { 'multi' => 1, safe => 1 }
        );
    }
}
