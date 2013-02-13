use t::common;
use parent qw(Test::Class);

use Test::Fatal;

use Play::Quests;

sub setup :Tests(setup) {
    Play::Users->new->collection->remove({});
    Dancer::session->destroy;
}

sub like_quest_internal :Tests {
    my $quests = Play::Quests->new;
    my $quest = $quests->add({
        user => 'blah',
        name => 'foo, foo',
        status => 'open',
    });
    my $id = $quest->{_id};

    $quests->like($id, 'user1');
    $quests->like($id, 'user2');

    # double like is idempotent
    $quests->like($id, 'user2');

    cmp_deeply
        $quests->get($id),
        {
            _id => re('^\S+$'),
            ts => re('^\d+$'),
            likes => [
                'user1', 'user2'
            ],
            name => 'foo, foo',
            status => 'open',
            user => 'blah',
        };
}

sub self_like_quest_internal :Tests {
    my $quests = Play::Quests->new;
    my $quest = $quests->add({
        user => 'blah',
        name => 'foo, foo',
        status => 'open',
    });
    my $id = $quest->{_id};

    like exception { $quests->like($id, 'blah') }, qr/unable to like your own quest/;
}

sub like_quest :Tests {
    Dancer::session login => 'blah';
    my $result = http_json POST => '/api/quest', { params => {
        name => 'foo',
    } };
    my $id = $result->{_id};
    like $id, qr/^\S+$/, 'quest add id';

    my $response = dancer_response POST => "/api/quest/$id/like"; # self-like!
    is $response->status, 500, 'self-like is forbidden';
    like $response->content, qr/unable to like your own quest/;

    Dancer::session login => 'blah2';
    http_json POST => "/api/quest/$id/like";

    Dancer::session login => 'blah3';
    http_json POST => "/api/quest/$id/like";

    # double-like
    Dancer::session login => 'blah3';
    http_json POST => "/api/quest/$id/like";

    my $quest = http_json GET => "/api/quest/$id";
    is_deeply $quest->{likes}, ['blah2', 'blah3'], 'got quest with likes';
}

__PACKAGE__->new->runtests;
