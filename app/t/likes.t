use t::common;
use parent qw(Test::Class);

use Play::Quests;

sub like_internal :Tests {
    my $quests = Play::Quests->new;
    my $id = $quests->add({
        user => 'blah',
        name => 'foo, foo',
        status => 'open',
    });

    my $updated;
    $updated = $quests->like($id, 'blah');
    is $updated, 1;

    $updated = $quests->like($id, 'blah2');
    is $updated, 1;

    $updated = $quests->like($id, 'blah2');
    is $updated, 1; # mongodb doesn't consider old version of the row and returns '1' anyway

    cmp_deeply
        $quests->get($id),
        {
            _id => re('^\S+$'),
            likes => [
                'blah', 'blah2'
            ],
            name => 'foo, foo',
            status => 'open',
            user => 'blah',
        };
}

__PACKAGE__->new->runtests;
