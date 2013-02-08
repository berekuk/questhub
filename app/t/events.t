use t::common;
use parent qw(Test::Class);

use Play::Events;

sub setup :Tests(setup) {
    Dancer::session->destroy;
    reset_db();
}

sub add_event :Tests {
    my $events = Play::Events->new;
    $events->add({ blah => 5, boo => 6 });
    $events->add({ foo => 'bar' });

    cmp_deeply(
        $events->list,
        [
            { foo => 'bar', ts => re('^\d+$'), _id => re('^\S+$') }, # last in, first out
            { blah => 5, boo => 6, ts => re('^\d+$'), _id => re('^\S+$') },
        ]
    );
}

sub events_limit :Tests {
    my $events = Play::Events->new;
    $events->add({ name => "e$_" }) for (1 .. 200);

    is scalar @{ $events->list }, 100;
}
__PACKAGE__->new->runtests;
