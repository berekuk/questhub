#!/usr/bin/env perl

use 5.014;
use warnings;

use DateTime;
use autodie qw(:all);
use IPC::System::Simple;

use lib '/play/backend/lib';
use Play::Mongo;

my $result_collection = Play::Mongo->db->get_collection('result');
my $tmp_collection = Play::Mongo->db->get_collection('users_tmp');
my $users_collection = Play::Mongo->db->get_collection('users');

sub process_file {
    my $file = shift;
    system "tar xfvz $file >/dev/null";
    system "cp dump/play/users.bson . && rm dump/play/* && mv users.bson dump/play/";

    system "mongorestore --drop --collection users_tmp --db play dump/play/";

    my @users = $tmp_collection->find->all;
    for my $user (@users) {
        $result_collection->update(
            { login => $user->{login} },
            { '$set' => { login => $user->{login} } },
            { safe => 1, upsert => 1 }
        );
        my $result = $result_collection->update(
            { login => $user->{login} },
            {
                '$push' => {
                    rph => {
                        '$each' => [ $user->{rp} || {} ]
                    }
                }
            },
            { safe => 1 }
        );
        unless ($result->{n}) {
            die "Oops";
        }
    }
}

sub fill_users_rph {
    my @result = $result_collection->find->all;
    for my $result (@result) {
        $users_collection->update(
            { login => $result->{login} },
            { '$set' => { rph => $result->{rph} } },
            { safe => 1 }
        );
    }
}

sub main {
    my $dt = DateTime->today;
    my $DEPTH = 9;
    $dt->subtract(days => 7 * $DEPTH);

    $_->drop for $result_collection, $tmp_collection;

    my $prev;
    for (1 .. $DEPTH) {
        my $file;
        for (1..7) {
            $dt->add(days => 1);
            my $date = $dt->date;
            $file = "$date.tar.gz";
            unless (-e $file) {
                $file = $prev;
            }
            $prev = $file;
        }
        say $file;
        process_file($file);
    }

    fill_users_rph();
}

main unless caller;
