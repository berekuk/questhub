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
    require Play::Quests;
    return Play::Quests->new;
}

sub events {
    require Play::Events;
    return Play::Events->new;
}

sub users {
    require Play::Users;
    return Play::Users->new;
}

sub comments {
    require Play::Comments;
    return Play::Comments->new;
}

1;
