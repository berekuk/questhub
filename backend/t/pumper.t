#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';
use Test::More;

BEGIN {
    $ENV{PLAY_CONFIG_FILE} = '/play/backend/t/data/config.yml';
    $ENV{EMAIL_SENDER_TRANSPORT} = 'Test';
}
use Email::Sender::Simple;
use Play::Flux;

use Log::Any::Test;
use Log::Any qw($log);

my $pumper = (require 'pumper/sendmail.pl')->new;

$pumper->run;
$log->contains_ok(qr/0 emails sent/);
$log->clear;

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
