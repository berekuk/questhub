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
        note => 'Just do anything',
    } };
}

sub list :Tests {
    http_json GET => "/api/fakeuser/foo";

    http_json POST => "/api/stencil", { params => {
        realm => 'europe',
        name => 'Do something',
        note => 'Just do anything',
    } };
    http_json POST => "/api/stencil", { params => {
        realm => 'europe',
        name => 'Do something else',
    } };

    my $result = http_json GET => "/api/stencil?realm=europe";
    cmp_deeply $result, [
        # TODO - sorting order?
        superhashof({
            name => 'Do something',
            note => 'Just do anything',
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
    cmp_deeply $stencil, superhashof {
        name => 'Do something',
        realm => 'europe',
        author => 'foo',
        _id => re('^\w{24}$'),
        ts => re('^\d+$'),
    };
}

sub take :Tests {
    http_json GET => "/api/fakeuser/foo";

    my $result = http_json POST => "/api/stencil", { params => {
        realm => 'europe',
        name => 'Do something',
    } };

    my $take_result = http_json POST => "/api/stencil/$result->{_id}/take";
    cmp_deeply $take_result, superhashof {
        author => 'foo',
        name => 'Do something',
        realm => 'europe',
    };

    my $quests = http_json GET => "/api/quest?user=foo";
    cmp_deeply $quests, [
        superhashof({
            author => 'foo',
            name => 'Do something',
            realm => 'europe',
        }),
    ];
}

sub edit :Tests {
    http_json GET => "/api/fakeuser/foo";

    my $add_result = http_json POST => "/api/stencil", { params => {
        realm => 'europe',
        name => 'Do something',
    } };

    my $edit_result = http_json PUT => "/api/stencil/$add_result->{_id}", { params => {
        name => "Do something else",
    } };

    my $stencil = http_json GET => "/api/stencil/$add_result->{_id}";
    cmp_deeply $stencil, superhashof {
        name => 'Do something else',
        realm => 'europe',
        author => 'foo',
        _id => re('^\w{24}$'),
        ts => re('^\d+$'),
    };
}

__PACKAGE__->new->runtests;
