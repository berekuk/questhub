use 5.010;

use lib 'lib';
use Play::Test::App;
use parent qw(Test::Class);

use Play::DB qw(db);

sub setup :Tests(setup => no_plan) {
    Dancer::session->destroy;
    reset_db();
}

sub update :Tests {
    http_json GET => '/api/fakeuser/foo';

    http_json PUT => '/api/realm/europe', { params => {
        name => 'Foo Realm',
        description => 'Conquered by foo',
    } };
    my $result = http_json GET => '/api/realm/europe';
    cmp_deeply
        $result,
        superhashof {
            name => 'Foo Realm',
            description => 'Conquered by foo',
            pic => 'europe.jpg',
        };

    http_json GET => '/api/fakeuser/bar';
    my $response = dancer_response PUT => '/api/realm/europe', { params => {
        name => 'Foo Realm',
        description => 'Conquered by foo',
    } };
    is $response->status, 500, 'only realm keeper can edit the realm';
}

__PACKAGE__->new->runtests;
