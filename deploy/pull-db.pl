#!/usr/bin/env perl

=head1 SYNOPSIS

    pull-db.pl [--production]
    options:
      --production      Pull from questhub.io instead of dropbox backup
      --keep-settings   Don't clean up email and other sensitive settings

=cut

use strict;
use warnings;

use 5.010;

use Getopt::Long 2.33;
use Pod::Usage;

use IPC::System::Simple;
use autodie qw(system);

sub docker_do {
    my ($container, @args) = @_;
    system('docker', 'exec', '-it', "questhub_${container}_1", @args);
}

sub mongo_do {
    docker_do('mongo', @_);
}

sub backend_do {
    docker_do('backend', @_);
}

sub main {
    my $from_production;
    my $keep_settings;
    GetOptions(
        'p|production!' => \$from_production,
        'k|keep-settings!' => \$keep_settings,
    ) or pod2usage(2);
    pod2usage(2) if @ARGV;

    my $HOST = 'questhub.io';

    backend_do('./clear_mongo.sh');
    mongo_do('mongo', 'play', '--eval', 'db.realms.drop()');

    system('rm -rf dump');
    system('mkdir dump');

    if ($from_production) {
        system(qq{ssh ubuntu\@$HOST "sh -c 'rm -rf dump && mongodump -d play'"});
        system(qq{scp -r ubuntu\@$HOST:dump/play ./dump/play});
    }
    else {
        my $backup_file = qx(ls -t1 ~/Dropbox/backup/$HOST/ | head -1);
        unless (defined $backup_file) {
            die "backup file not found: $!";
        }
        chomp $backup_file;

        system("tar xfvz ~/Dropbox/backup/$HOST/$backup_file");
    }

    system("tar -c dump | docker exec -i questhub_mongo_1 bash -c 'cd /data && rm -rf dump && tar -xv && cd dump && mongorestore --drop .'");

    # to avoid accidentally sending emails to users while debugging
    mongo_do('mongo', 'play', '--eval', 'db.users.update({}, {"$unset": { "settings" : 1 } }, false, true)') unless $keep_settings;
}

main unless caller;
