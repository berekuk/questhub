package Play::Test::App;

use strict;
use warnings;

use 5.010;

use parent qw(Exporter);
our @EXPORT = qw( http_json register_email process_email_queue );

use lib '../backend/lib';

BEGIN {
    $ENV{DEV_MODE} = 1;
}

use Import::Into;

sub http_json {
    my ($method, $url, @rest) = @_;
    my $response = Dancer::Test::dancer_response($method => $url, @rest);
    Test::More::is($response->status, 200, "$method => $url status code") or Test::More::diag($response->content);

    if (ref $response->content eq 'GLOB') {
        my $fh = $response->content;
        local $/ = undef;
        $response->content(join '', <$fh>);
    }

    return JSON::decode_json($response->content);
}

# register_email 'foo' => { email => 'a@b.com', notify_likes => 1 }
# email will be confirmed automatically
# user must be logged in
sub register_email {
    my ($user, $settings) = @_;

    http_json PUT => '/api/current_user/settings', { params => $settings };

    my @deliveries = process_email_queue();
    my ($secret) = $deliveries[0]->{email}->get_body =~ qr/(\d+)</;
    http_json POST => "/api/register/confirm_email", { params => { login => $user, secret => $secret } };
    process_email_queue();
    return;
}

sub process_email_queue {
    state $email_pumper = (require '/play/backend/pumper/sendmail.pl')->new;

    Email::Sender::Simple->default_transport->clear_deliveries;
    my @t = Email::Sender::Simple->default_transport->deliveries;
    $email_pumper->run;

    my @deliveries = Email::Sender::Simple->default_transport->deliveries;
    return @deliveries;
}

sub import {
    my $target = caller;

    require JSON; JSON->import::into($target, qw(decode_json encode_json));
    require Play::Test; Play::Test->import::into($target);

    # the order is important
    require Dancer; Dancer->import::into($target);
    require Play; Play->import::into($target);
    require Dancer::Test; Dancer::Test->import::into($target);

    __PACKAGE__->export_to_level(1, @_);
}

1;
