#!/usr/bin/env perl

use strict;
use warnings;

use 5.010;

use lib 'lib';
use Play::Mongo;

my @settings = Play::Mongo->db->get_collection('user_settings')->find()->all();

my $users = Play::Mongo->db->get_collection('users');

for my $settings (@settings) {
    my $login = delete $settings->{user};
    delete $settings->{_id};
    die unless $login;

    $users->update(
        { login => $login },
        { '$set' => { settings => $settings } },
        { safe => 1 }
    );
}

use Play::DB qw(db);
db->ensure_indices();
