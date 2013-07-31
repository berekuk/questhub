#!/usr/bin/env perl
package bin::pumper::sendmail;

use lib '/play/backend/lib';

use Moo;
use MooX::Options;
with 'Play::Pumper';

use Play::Flux;
use Play::Config qw(setting);

use Play::DB qw(db);

use Play::Email;
use Email::Simple;
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

        $self->in->commit; # it's better to lose the email than to spam a user indefinitely

        my ($address, $subject, $body, $notify_field);
        if (ref $item eq 'ARRAY') {
            ($address, $subject, $body) = @$item;
        }
        else {
            ($address, $subject, $body) = @$item{qw/ address subject body /}; # TODO - validate?

            if ($item->{login} and $item->{notify_field}) {
                my $secret = db->users->unsubscribe_secret($item->{login});
                $body .= q{
                <div style="margin-top: 30px; text-align: center; margin-bottom: 30px;">
                  <hr>
                  <span style="font-size: 12px">
                    Don't want to receive these emails? <a href="http://}.setting('hostport').qq[/api/user/$item->{login}/unsubscribe/$item->{notify_field}?secret=$secret">Unsubscribe</a> at any time.
                  </span>
                </div>
                ];
            }
        }

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

        Play::Email->sendmail($email);
        $self->add_stat('emails sent');
    }
}

__PACKAGE__->run_script;
