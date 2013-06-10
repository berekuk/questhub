package Play::DB;

use 5.010;

use Moo;

use Play::Mongo;

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

sub notifications {
    require Play::DB::Notifications;
    return Play::DB::Notifications->new;
}

sub images {
    require Play::DB::Images;
    return Play::DB::Images->new;
}

sub ensure_indices {
    my $users_collection = Play::Mongo->db->get_collection('users');
    $users_collection->drop_indexes; # yeah! (FIXME)
    $users_collection->ensure_index({ 'login' => 1 }, { unique => 1 });
    $users_collection->ensure_index({ 'twitter.login' => 1 }, { unique => 1, sparse => 1 });
    $users_collection->ensure_index({ 'settings.email' => 1 }, { unique => 1, sparse => 1 });

    my $quests_collection = Play::Mongo->db->get_collection('quests');
    $quests_collection->drop_indexes;
    $quests_collection->ensure_index({ 'tags' => 1 });
    $quests_collection->ensure_index({ 'team' => 1 });
    $quests_collection->ensure_index({ 'watchers' => 1 });
    $quests_collection->ensure_index({ 'realm' => 1 });
}

1;
