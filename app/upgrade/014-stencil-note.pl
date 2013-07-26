#!/usr/bin/env perl

use strictures 1;
use 5.012;

use lib '/play/backend/lib';
use Play::Mongo;
use Data::Dumper;

my $sc = Play::Mongo->db->get_collection('stencils');
my $qc = Play::Mongo->db->get_collection('quests');

my @stencils = $sc->find->all;
my @quests = $qc->find->all;

# copy stencil.description to quest.note
# remove quest.description if it's equal to note
for my $quest (@quests) {
    next unless $quest->{stencil};

    my ($stencil) = grep { $_->{_id}->value eq $quest->{stencil} } @stencils;
    die Dumper($quest) unless $stencil;

    my $note = $stencil->{description};
    next unless $note;

    my $clear_description = ($note eq $quest->{description});
    if (grep { $_ eq $quest->{_id}->value } qw( 51ded4fc05581e3220000005 51e5080e91198f2121000036 51e6891ac110d61d4600002e 51e84b607deb5b8018000029 51f0ccf718ba7d3b4c000022 )) {
        $clear_description = 1;
    }

    $qc->update(
        { _id => $quest->{_id} },
        {
            '$set' => { note => $note },
            (
                $clear_description
                ? ('$unset' => { description => '' })
                : ()
            )
        },
        { safe => 1 }
    );
}

# { "_id" : ObjectId("51e2f3e791198f3b450000c7") }
# { "_id" : ObjectId("51e705427deb5b752c000006") }
