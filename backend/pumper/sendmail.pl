#!/usr/bin/env perl
package bin::pumper::sendmail;

use lib '/play/backend/lib';

use Moo;
use MooX::Options;
with 'Play::Pumper';

use Play::Flux;
use Play::Config qw(setting);

use Email::Simple;
use Email::Sender::Simple qw(sendmail);
use Encode qw(encode_utf8);

has 'in' => (
    is => 'lazy',
    default => sub {
        return Play::Flux->email->in('/data/storage/email/pos');
    },
);

sub run_once {
    my $self = shift;

    while (my $item = $self->in->read) {
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
        $self->in->commit; # it's better to lose the email than to spam a user indefinitely
        sendmail($email);
        $self->add_stat('emails sent');
    }
}

__PACKAGE__->run_script;
