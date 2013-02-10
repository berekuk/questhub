package t::common;

use strict;
use warnings;

use parent qw(Exporter);
our @EXPORT = qw( http_json reset_db );

use lib 'lib';
use Import::Into;

BEGIN {
    $ENV{DEV_MODE} = 1;
}

use Play::Mongo qw(:test);

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

sub reset_db {
    for (qw/ quests comments users events user_settings /) {
        Play::Mongo->db->get_collection($_)->remove({});
    }
}

sub import {
    my $target = caller;

    require Test::More; Test::More->import::into($target, import => ['!pass']);
    require Test::Deep; Test::Deep->import::into($target, qw(cmp_deeply re));
    require JSON; JSON->import::into($target, qw(decode_json));

    # the order is important
    require Dancer; Dancer->import::into($target);
    require Play; Play->import::into($target);
    require Dancer::Test; Dancer::Test->import::into($target);

    __PACKAGE__->export_to_level(1, @_);
}

1;
