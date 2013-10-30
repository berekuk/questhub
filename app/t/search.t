use 5.010;

use lib 'lib';
use Play::Test::App;
use parent qw(Test::Class);

sub setup :Tests(setup => no_plan) {
    Dancer::session->destroy;
    reset_db();
}

sub search :Tests {
    http_json GET => "/api/fakeuser/foo";
    my @quests = map {
        http_json POST => '/api/quest', { params => { name => $_, realm => 'europe' } }
    }
    (
        (map { "quest number $_ " } 1..5),
        "something else",
    );

    my $result = http_json GET => "/api/search?q=oops";
    cmp_deeply $result, [];

    $result = http_json GET => "/api/search?q=something";
    cmp_deeply $result, [ignore];

    $result = http_json GET => "/api/search?q=number";
    cmp_deeply $result, [ignore, ignore, ignore, ignore, ignore];
}

__PACKAGE__->new->runtests;
