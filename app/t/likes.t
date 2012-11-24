use t::common;
use parent qw(Test::Class);

use Test::Fatal;

use Play::Quests;

sub setup :Tests(setup) {
    Play::Users->new->collection->remove({});
    Dancer::session->destroy;
}

sub like_internal :Tests {
    my $quests = Play::Quests->new;
    my $id = $quests->add({
        user => 'blah',
        name => 'foo, foo',
        status => 'open',
    });

    $quests->like($id, 'user1');
    $quests->like($id, 'user2');

    # double like is idempotent
    $quests->like($id, 'user2');

    cmp_deeply
        $quests->get($id),
        {
            _id => re('^\S+$'),
            likes => [
                'user1', 'user2'
            ],
            name => 'foo, foo',
            status => 'open',
            user => 'blah',
        };
}

sub self_like_internal :Tests {
    my $quests = Play::Quests->new;
    my $id = $quests->add({
        user => 'blah',
        name => 'foo, foo',
        status => 'open',
    });

    like exception { $quests->like($id, 'blah') }, qr/unable to like your own quest/;
}

__PACKAGE__->new->runtests;
