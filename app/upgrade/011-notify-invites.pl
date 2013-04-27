#!/usr/bin/env perl

use strictures 1;

use 5.010;

use lib '/play/backend/lib';
use Play::Mongo;

my $uc = Play::Mongo->db->get_collection('users');
my @users = $uc->find->all;
for my $user (@users) {
    if ($user->{settings}{notify_comments}) {
        $uc->update(
            { _id => $user->{_id} },
            { '$set' => { 'settings.notify_invites' => 1 } },
            { safe => 1 }
        );
    }
}
