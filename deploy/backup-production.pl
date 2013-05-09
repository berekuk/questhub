#!/usr/bin/env perl

use strict;
use warnings;

=head1 SYNOPSIS

  backup-production.pl

=cut

use Getopt::Long 2.33;
use Pod::Usage;

use IPC::System::Simple;
use autodie qw(:all);

sub main {
    GetOptions() or pod2usage(2);

    pod2usage(2) unless @ARGV == 0;
    my $name = 'questhub.io';

    system(qq{ssh ubuntu\@$name "sh -c 'rm -rf dump && rm -f backup.tar.gz && mongodump -d play && tar cfvz backup.tar.gz dump'"});
    system(qq{scp ubuntu\@$name:backup.tar.gz .});
    system(qq{mv backup.tar.gz ~/Dropbox/backup/$name/\$(date "+%Y-%m-%d").tar.gz});
}

main unless caller;
