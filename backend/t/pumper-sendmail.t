#!/usr/bin/perl

use lib 'lib';
use Play::Test;

use Email::Sender::Simple;
use Play::Flux;

use Log::Any qw($log);

my $pumper = require 'pumper/sendmail.pl';
$pumper = $pumper->new;

$pumper->run;
$log->empty_ok;

my $storage = Play::Flux->email;
$storage->write(['test@example.com', 'test title', 'test body']);
$storage->write(['test2@example.com', 'test title 2', 'test body 2']);
$storage->commit;

$pumper->run;
$log->contains_ok(qr/2 emails sent/);
$log->clear;

my @deliveries = Email::Sender::Simple->default_transport->deliveries;
is scalar @deliveries, 2;

done_testing;
