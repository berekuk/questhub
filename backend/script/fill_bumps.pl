#!/usr/bin/env perl

=head1 DESCRIPTION

Fills C<quests.bump> field.

This script is temporary and can be removed after feed-2.0 branch is deployed.

=cut

use 5.014;
use warnings;
use lib '/play/backend/lib';

use Play::DB qw(db);
use List::Util qw(max);

binmode STDOUT, ':utf8';

sub main {
    my @quests = db->quests->collection->find->all;

    my $i = 0;
    my $total = scalar @quests;
    say "Updating $total quests";

    for my $quest (@quests) {
        say "$i / $total" unless $i++ % 100;
        $quest = db->quests->_prepare_quest($quest);
        my $bump = $quest->{ts};

        my $comments = db->comments->list('quest', $quest->{_id});
        $bump = max map { $_->{ts} } @$comments if @$comments;

        db->quests->collection->update(
            { _id => MongoDB::OID->new(value => $quest->{_id}) },
            { '$set' => { bump => $bump } },
            { safe => 1 }
        );
    }
    say "$total / $total";
}


main unless caller;
