#!/usr/bin/env perl

use strict;
use warnings;

use IPC::System::Simple;
use autodie qw(:all);

sub main {
    my $action = shift;
    $action ||= 'abf';
    system('cd backend && prove') if $action =~ /b/;
    system('cd app && prove') if $action =~ /a/;
    system('phantomjs ./www/tools/run-jasmine.js http://localhost:81/test/index.html') if $action =~ /f/;
}

main(@ARGV) unless caller;
