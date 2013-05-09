#!/usr/bin/env perl

use strictures 1;

use 5.010;

use lib '/play/backend/lib';
use Play::Mongo;

my $ec = Play::Mongo->db->get_collection('events');
my @events = $ec->find->all;
for my $event (@events) {
    next if defined $event->{type}; # already upgraded

    $event->{type} = "$event->{action}-$event->{object_type}";

    if ($event->{object_type} eq 'comment') {
        $event->{comment_id} = delete $event->{object_id};
        $event->{quest_id} = delete $event->{object}{quest}{_id};
    }
    elsif ($event->{object_type} eq 'quest') {
        $event->{quest_id} = delete $event->{object_id};
        if ($event->{action} eq 'invite') {
            $event->{invitee} = delete $event->{object}{invitee};
        }
    }
    elsif ($event->{object_type} eq 'user') {
        $event->{user_id} = delete $event->{object_id};
    }

    delete $event->{action};
    delete $event->{object_type};
    delete $event->{object};

    $ec->update(
        { _id => $event->{_id} },
        $event,
        { safe => 1 }
    );
}
