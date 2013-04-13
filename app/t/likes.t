use lib 'lib';
use Play::Test::App;
use parent qw(Test::Class);

use Play::DB qw(db);

sub setup :Tests(setup) {
    reset_db();
    Dancer::session->destroy;
}

sub like_quest :Tests {
    http_json GET => "/api/fakeuser/blah";
    my $result = http_json POST => '/api/quest', { params => {
        name => 'foo',
    } };
    my $id = $result->{_id};
    like $id, qr/^\S+$/, 'quest add id';

    my $response = dancer_response POST => "/api/quest/$id/like"; # self-like!
    is $response->status, 500, 'self-like is forbidden';
    like $response->content, qr/unable to like your own quest/;

    http_json GET => "/api/fakeuser/blah2";
    http_json POST => "/api/quest/$id/like";

    http_json GET => "/api/fakeuser/blah3";
    http_json POST => "/api/quest/$id/like";

    # double like
    my $response = dancer_response POST => "/api/quest/$id/like";
    is $response->status, 500, 'double like is forbidden';

    my $quest = http_json GET => "/api/quest/$id";
    is_deeply $quest->{likes}, ['blah2', 'blah3'], 'got quest with likes';
}

__PACKAGE__->new->runtests;
