use lib 'lib';
use Play::Test::App;
use parent qw(Test::Class);

use Play::DB qw(db);

sub setup :Tests(setup) {
    Dancer::session->destroy;
    reset_db();
}

sub limit_offset :Tests {
    db->events->add({ name => "e$_", type => 'add-test', realm => 'europe' }) for (1 .. 200);

    my $list = http_json GET => '/api/event?realm=europe';
    is scalar @$list, 100;

    $list = http_json GET => '/api/event?limit=30&realm=europe';
    is scalar @$list, 30;
    cmp_deeply
        [ map { $_->{name} } @$list ],
        [ map { "e$_" } reverse 171 .. 200 ];

    $list = http_json GET => '/api/event?limit=30&offset=50&realm=europe';
    is scalar @$list, 30;
    cmp_deeply
        [ map { $_->{name} } @$list ],
        [ map { "e$_" } reverse 121 .. 150 ];
}

sub list :Tests {
    db->events->add({ blah => 5, type => 'add-test', realm => 'europe' });
    db->events->add({ blah => 6, type => 'add-test', realm => 'europe' });

    my $list = http_json GET => '/api/event?realm=europe';
    cmp_deeply
        $list,
        [
            superhashof({ blah => 6, _id => re('^\S+$'), ts => re('^\d+$'), type => 'add-test', realm => 'europe' }),
            superhashof({ blah => 5, _id => re('^\S+$'), ts => re('^\d+$'), type => 'add-test', realm => 'europe' }),
        ]
}

sub filter_list :Tests {
    http_json GET => "/api/fakeuser/foo";

    my $q1 = http_json POST => '/api/quest', { params => {
        user => 'foo',
        name => 'q1',
        realm => 'europe'
    } };
    http_json POST => "/api/quest/$q1->{_id}/close";
    http_json POST => "/api/quest/$q1->{_id}/reopen";
    http_json POST => "/api/quest/$q1->{_id}/comment", { params => {
        body => 'c1',
    } };

    my $list = http_json GET => '/api/event?types=add-comment,reopen-quest&realm=europe';
    cmp_deeply
        $list,
        [
            superhashof({ type => 'add-comment', _id => re('^\S+$'), ts => re('^\d+$'), realm => 'europe' }),
            superhashof({ type => 'reopen-quest', _id => re('^\S+$'), ts => re('^\d+$'), realm => 'europe' }),
        ]
}

sub atom :Tests {
    # add-user event
    http_json GET => '/api/fakeuser/Frodo';

    # add-quest event
    my $add_result = http_json POST => '/api/quest', { params => {
        user => 'Frodo',
        name => 'Destroy the Ring',
        realm => 'europe' # FIXME - Middle-earth!
    } };

    # Regular Atom
    my $response = dancer_response GET => '/api/event/atom?realm=europe';
    is $response->status, 200;
    like $response->content, qr/Frodo joins europe realm/;

    # Atom has filter.
    $response = dancer_response GET => '/api/event/atom?types=add-quest&realm=europe';
    is $response->status, 200;
    unlike $response->content, qr/Frodo joins europe realm/;
}

__PACKAGE__->new->runtests;
