#!/usr/bin/perl

use lib 'lib';
use Play::Test;

use Email::Sender::Simple;
use Play::Flux;

use Log::Any qw($log);

my $pumper = pumper('sendmail');

$pumper->run;
$log->empty_ok;

my $storage = Play::Flux->email;
$storage->write(['test@example.com', 'test title', 'test body 1']);
$storage->write(['test2@example.com', 'test title 2', 'test body 2']);
$storage->write({
    address => 'test3@example.com',
    subject => 'test title 3',
    body => 'test body 3',
});
$storage->commit;

$pumper->run;
$log->contains_ok(qr/3 emails sent/);
$log->clear;

my @deliveries = Email::Sender::Simple->default_transport->deliveries;
is scalar @deliveries, 3;

cmp_deeply
    [ map { $_->{email}->get_body } @deliveries ],
    [ map { "test body $_\r\n" } (1..3) ];
Email::Sender::Simple->default_transport->clear_deliveries;

done_testing;
