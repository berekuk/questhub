package Play::Mongo;

use strict;
use warnings;
use MongoDB;

sub db {
    my $connection = MongoDB::Connection->new(host => 'localhost', port => 27017);
    my $db = $ENV{TEST_DB} || 'play';
    return $db;
}

1;
