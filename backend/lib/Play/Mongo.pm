package Play::Mongo;

use strict;
use warnings;
use MongoDB;

use Play::Config qw(setting);

sub db {
    my $connection = MongoDB::Connection->new(host => 'localhost', port => 27017);
    my $db = $ENV{TEST_DB} || 'play';
    return $connection->get_database($db);
}

if (setting('test')) {
    $ENV{TEST_DB} = 'play_test';
    db->get_collection('users')->remove;
    db->get_collection('quests')->remove;
}

1;
