#!/usr/bin/env perl

=head1 SYNOPSIS

    pull-db.pl

=cut

use strict;
use warnings;

use 5.010;

use Getopt::Long 2.33;
use Pod::Usage;

use IPC::System::Simple;
use autodie qw(system);

sub main {
    GetOptions() or pod2usage(2);
    pod2usage(2) if @ARGV;

    system(q{vagrant ssh -c 'cd /play/app && ./clear_mongo.sh'});

    system('rm -rf dump');
    system('mkdir dump');

    system(q{ssh ubuntu@questhub.io "sh -c 'rm -rf dump && mongodump -d play'"});
    system(q{scp -r ubuntu@questhub.io:dump/play ./dump/play});

    system(q{vagrant ssh -c 'cd /play && mongorestore'});

    # to avoid accidentally sending emails to users while debugging
    system(q[vagrant ssh -c '(echo '\''use play'\''; echo '\''db.users.update({}, {"$unset": { "settings" : 1 } }, false, true)'\'') | mongo']);
}

main unless caller;
