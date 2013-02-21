package Play::DB;

use 5.010;

use Moo;

use parent qw(Exporter);
our @EXPORT_OK = qw( db );

# TODO - singleton
sub db {
    return __PACKAGE__->new;
}

sub quests {
    require Play::DB::Quests;
    return Play::DB::Quests->new;
}

sub events {
    require Play::DB::Events;
    return Play::DB::Events->new;
}

sub users {
    require Play::DB::Users;
    return Play::DB::Users->new;
}

sub comments {
    require Play::DB::Comments;
    return Play::DB::Comments->new;
}

1;
