#!/usr/bin/env perl

use strictures 1;
use 5.012;
use lib '/play/backend/lib';

use Play::Mongo;
use List::Util qw(max);

sub main {
    my $sc = Play::Mongo->db->get_collection('stencils');
    my $pc = Play::Mongo->db->get_collection('posts');
    my $cc = Play::Mongo->db->get_collection('comments');

    for my $entity (qw( quest stencil )) {
        my $collection = Play::Mongo->db->get_collection("${entity}s");

        for my $post ($collection->find->all) {
            $post->{entity} = $entity;

            $post->{bump} = $post->{_id}->get_time;
            my @comments = $cc->find({ eid => $post->{_id}->to_string, entity => $entity })->all;
            $post->{bump} = max map { $_->{_id}->get_time } @comments if @comments;

            $pc->insert($post, { safe => 1 });
        }
    }
}

main unless caller;
