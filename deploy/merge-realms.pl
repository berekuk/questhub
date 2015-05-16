#!/usr/bin/env perl

use strictures 1;
use 5.010;

use MongoDB;
use Data::Dumper;

use autodie qw(:all);

my $connection = MongoDB::Connection->new(host => 'localhost', port => 27017);

my $db = $connection->get_database("play");

my %users;
my @comments;
my @quests;
my @events;

system('./backend/clear_mongo.sh');

my @realms = qw( perl qh );
for my $realm (@realms) {
    my $realm_db = $connection->get_database("play-$realm");

    $realm = 'chaos' if $realm eq 'qh';

    {
        my @users = $realm_db->get_collection('users')->find->all;
        for my $user (@users) {

            next if $realm eq 'perl' and $user->{login} eq 'ruok';

            my $merged_user = $user;
            if ($users{$user->{login}}) {
                say "merging: $user->{login}";
                $merged_user = $users{$user->{login}};
            }

            delete $user->{settings}{email} if defined $user->{settings}{email} and $user->{settings}{email} eq '';
            $merged_user->{realms} ||= [];
            push @{ $merged_user->{realms} }, $realm;
            $merged_user->{rp} ||= {};
            $merged_user->{rp}{$realm} = ($user->{points} || 0);
            $users{$user->{login}} = $merged_user;
        }
    }

    {
        push @comments, $realm_db->get_collection('comments')->find->all;
    }

    {
        for my $event ($realm_db->get_collection('events')->find->all) {
            $event->{realm} = $realm;
            if ($event->{object_type} eq 'quest') {
                $event->{object}{realm} = $realm;
            }
            elsif ($event->{object_type} eq 'comment') {
                $event->{object}{quest}{realm} = $realm;

            }
            push @events, $event;
        }
    }

    {
        for my $quest ($realm_db->get_collection('quests')->find->all) {
            $quest->{realm} = $realm;
            push @quests, $quest;
        }
    }
}

for my $user (values %users) {
    $db->get_collection('users')->insert($user, { safe => 1 });
}

for my $comment (@comments) {
    $db->get_collection('comments')->insert($comment, { safe => 1 });
}

for my $event (@events) {
    $db->get_collection('events')->insert($event, { safe => 1 });
}


for my $quest (@quests) {
    $db->get_collection('quests')->insert($quest, { safe => 1 });
}
