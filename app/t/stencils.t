use 5.010;

use lib 'lib';
use Play::Test::App;
use parent qw(Test::Class);

sub setup :Tests(setup => no_plan) {
    Dancer::session->destroy;
    reset_db();
}

sub add :Tests {
    http_json GET => "/api/fakeuser/foo";

    http_json POST => "/api/stencil", { params => {
        realm => 'europe',
        name => 'Do something',
    } };
}

sub list :Tests {
    http_json GET => "/api/fakeuser/foo";

    http_json POST => "/api/stencil", { params => {
        realm => 'europe',
        name => 'Do something',
    } };
    http_json POST => "/api/stencil", { params => {
        realm => 'europe',
        name => 'Do something else',
    } };

    my $result = http_json GET => "/api/stencil?realm=europe";
    cmp_deeply $result, [
        superhashof({
            name => 'Do something', # TODO - sorting order?
        }),
        superhashof({
            name => 'Do something else',
        }),
    ];
}

sub get_one :Tests {
    http_json GET => "/api/fakeuser/foo";

    my $result = http_json POST => "/api/stencil", { params => {
        realm => 'europe',
        name => 'Do something',
    } };

    like $result->{_id}, qr/^\w{24}$/;
    my $stencil = http_json GET => "/api/stencil/$result->{_id}";
    cmp_deeply $stencil, {
        name => 'Do something',
        realm => 'europe',
        author => 'foo',
        _id => re('^\w{24}$'),
        ts => re('^\d+$'),
    };
}

__PACKAGE__->new->runtests;
