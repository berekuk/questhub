package Play::Mongo;

use strict;
use warnings;
use MongoDB;

sub import {
    my $class = shift;
    if (@_ == 1 and $_[0] eq ':test') {
        $ENV{TEST_DB} = 'play_test';
        $class->db->users->remove;
        $class->db->quests->remove;
    }
}

sub db {
    my $connection = MongoDB::Connection->new(host => 'localhost', port => 27017);
    my $db = $ENV{TEST_DB} || 'play';
    return $connection->db;
}

1;
