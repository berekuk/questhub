#!/usr/bin/env perl

use strictures 1;
use 5.012;

use lib '/play/backend/lib';
use Play::Mongo;

my $ec = Play::Mongo->db->get_collection('events');
my $cc = Play::Mongo->db->get_collection('comments');
my @events = $ec->find->all;

my %types = (
    'close-quest' => 'close',
    'abandon-quest' => 'abandon',
    'invite-quest' => 'invite',
    'reopen-quest' => 'reopen',
    'resurrect-quest' => 'resurrect',
);
for my $event (@events) {
    next if grep { $event->{type} eq $_ } qw/ add-quest add-user add-comment /;

    my $original_id = $event->{_id};

    # event ids are usually not equal to comment ids;
    # so I'm avoiding collisions in my generated comment ids to lower risks of making wrong assumptions later
    my $id = (delete $event->{_id})->to_string;
    substr($id, -1) = sprintf("%x", hex(substr($id, -1)) ^ 1);

    my $comment_type = $types{$event->{type}} or die "Unknown event type '$event->{type}'";
    delete $event->{type};

    delete $event->{realm};

    my $comment = {
        _id => MongoDB::OID->new(value => $id),
        quest_id => delete $event->{quest_id},
        author => delete $event->{author},
        type => $comment_type,
    };

    if ($comment_type eq 'invite') {
        $comment->{invitee} = delete $event->{invitee};
    }

    (defined $_ or die "No value") for values %$comment;

    if (keys %$event) {
        use Data::Dumper; die "Unexpected fields in event: ", Dumper($event);
    }

    $cc->insert($comment, { safe => 1 });

    $ec->update(
        { _id => $original_id },
        {
            '$set' => {
                type => 'add-comment',
                comment_id => $id,
            },
            '$unset' => { invitee => '' },
        },
        { safe => 1 },
    );
}


