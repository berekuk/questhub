#!/usr/bin/env perl
package script::backend_times;

=head1 SYNOPSIS

    backend_times.pl

=cut

use 5.012;
use warnings;
use lib '/play/backend/lib';
use Play::Config qw(setting);

sub main {
    my $access_log = setting('data_dir') . '/access.log';
    my @lines = split /\n/, qx(tac $access_log | fgrep ' /api' | head -1000); # TODO - make 1000 customizable

    for my $line (@lines) {
        next if $line =~ /^\S+ - - \[/; # old log format
        my ($request_time, $upstream_time) = $line =~ /
            \s (\d+\.\d+)
            \s ( - | \d+\.\d+ )
            \s (?: \. | p )
        $/x or die "Line '$line' looks weird";

        my ($route) = $line =~ m{ \] \s "\S+ \s /api/(\S+) \s HTTP }x or die "Route not found in line '$line'";

        say "$request_time\t$upstream_time\t$route";
        # TODO - aggregate statistics
        # TODO - separate routes from their parameters
    }
}

main unless caller;
