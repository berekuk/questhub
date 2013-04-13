#!/usr/bin/env perl
package bin::pumper::sendmail;

use strict;
use warnings;

use lib '/play/backend/lib';

use Lock::File 'lockfile';
use Log::Any '$log';

use Play::Flux;
use Play::Config qw(setting);

use Email::Simple;
use Email::Sender::Simple qw(sendmail);
use Encode qw(encode_utf8);

sub main {
    my $lock;
    unless (setting('test')) {
        $lock = lockfile('/data/pumper/sendmail.lock', { blocking => 0 }) or return;
    }

    my $storage = Play::Flux->email;
    my $in = $storage->in('/data/pumper/email/pos'); # FIXME - move from Flux::File to more advanced storage with named clients

    my $processed = 0;

    while (my $item = $in->read) {
        my ($address, $subject, $body) = @$item;

        my $email = Email::Simple->create(
            header => [
                To => $address,
                From => setting('service_name').' <notification@'.setting('hostport').'>',
                Subject => encode_utf8($subject),
                'Reply-to' => 'Vyacheslav Matyukhin <me@berekuk.ru>', # TODO - take from config
                'Content-Type' => 'text/html; charset=utf-8',
            ],
            body => encode_utf8($body),
        );
        sendmail($email);
        $in->commit;
        $processed++;
    }

    $log->info("$processed emails sent");
}

if (caller) {
    return __PACKAGE__;
}
else {
    require Log::Any::Adapter;
    Log::Any::Adapter->import('File', '/dev/stdout');
    main;
}
