package Play::DB;

use 5.010;

use Moo;

use Play::Mongo;
use Tie::IxHash;

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

sub realms {
    require Play::DB::Realms;
    return Play::DB::Realms->new;
}

sub stencils {
    require Play::DB::Stencils;
    return Play::DB::Stencils->new;
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
    $quests_collection->ensure_index({ 'stencil' => 1 });

    my $events_collection = Play::Mongo->db->get_collection('events');
    $events_collection->drop_indexes;
    $events_collection->ensure_index({ 'realm' => 1 });
    $events_collection->ensure_index({ 'author' => 1 });

    my $realms_collection = Play::Mongo->db->get_collection('realms');
    $realms_collection->drop_indexes;
    $realms_collection->ensure_index({ 'id' => 1 }, { unique => 1 });

    my $comments_collection = Play::Mongo->db->get_collection('comments');
    $comments_collection->drop_indexes;
    $comments_collection->ensure_index(
        Tie::IxHash->new(entity => 1, eid => 1)
    );
}

1;
