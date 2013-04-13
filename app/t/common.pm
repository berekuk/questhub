use parent qw(Exporter);
our @EXPORT = qw( http_json register_email );

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

sub import {
    my $target = caller;

    require Test::More; Test::More->import::into($target, import => ['!pass']);
    require Test::Deep; Test::Deep->import::into($target, qw(cmp_deeply re superhashof ignore));
    require JSON; JSON->import::into($target, qw(decode_json encode_json));

    # the order is important
    require Dancer; Dancer->import::into($target);
    require Play; Play->import::into($target);
    require Dancer::Test; Dancer::Test->import::into($target);

    use Play::DB qw(db);
    db->ensure_indices();

    __PACKAGE__->export_to_level(1, @_);
}

1;
