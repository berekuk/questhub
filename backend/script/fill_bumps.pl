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
    my @entities = @_;
    @entities = qw( quest stencil ) unless @entities;
    for my $entity (@entities) {
        my $db_method = "${entity}s";
        my @objects = db->$db_method->collection->find->all;

        my $i = 0;
        my $total = scalar @objects;
        say "Updating $total ${entity}s";

        for my $object (@objects) {
            say "$i / $total" unless $i++ % 100;
            $object = db->$db_method->_prepare($object);
            my $bump = $object->{ts};

            my $comments = db->comments->list($entity, $object->{_id});
            $bump = max map { $_->{ts} } @$comments if @$comments;

            db->$db_method->collection->update(
                { _id => MongoDB::OID->new(value => $object->{_id}) },
                { '$set' => { bump => $bump } },
                { safe => 1 }
            );
        }
        say "$total / $total";
    }
}


main(@ARGV) unless caller;
