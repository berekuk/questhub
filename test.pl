#!/usr/bin/env perl

use strict;
use warnings;

use IPC::System::Simple;
use autodie qw(:all);

system('cd backend && prove');
system('cd app && prove');
system('phantomjs ./www/tools/run-jasmine.js http://localhost:81/test/index.html');
