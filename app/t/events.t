use lib 'lib';
use Play::Test::App;
use parent qw(Test::Class);

use Play::DB qw(db);

sub setup :Tests(setup) {
    Dancer::session->destroy;
    reset_db();
}

sub limit_offset :Tests {
    db->events->add({ name => "e$_", realm => 'europe' }) for (1 .. 200);

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
    db->events->add({ blah => 5, realm => 'europe' });
    db->events->add({ blah => 6, realm => 'europe' });

    my $list = http_json GET => '/api/event?realm=europe';
    cmp_deeply
        $list,
        [
            { blah => 6, _id => re('^\S+$'), ts => re('^\d+$'), realm => 'europe' },
            { blah => 5, _id => re('^\S+$'), ts => re('^\d+$'), realm => 'europe' },
        ]
}

sub filter_list :Tests {
    db->events->add({ object => 'NEW_QUEST', object_type => 'quest', action => 'add', realm => 'europe' });
    db->events->add({ object => 'REOPEN_QUEST', object_type => 'quest', action => 'reopen', realm => 'europe' });
    db->events->add({ object => 'OLD_QUEST', object_type => 'comment', action => 'add', realm => 'europe' });

    # Want add-comment.
    my $list = http_json GET => '/api/event?types=add-comment,reopen-quest&realm=europe';
    cmp_deeply
        $list,
        [
            { object => 'OLD_QUEST', object_type => 'comment', action => 'add' , _id => re('^\S+$'), ts => re('^\d+$'), realm => 'europe' },
            { object => 'REOPEN_QUEST', object_type => 'quest', action => 'reopen' , _id => re('^\S+$'), ts => re('^\d+$'), realm => 'europe' },
        ]
}

sub atom :Tests {
    # add-user event
    http_json GET => '/api/fakeuser/Frodo';

    # add-quest event
    my $add_result = http_json POST => '/api/quest', { params => {
        user => 'Frodo',
        name => 'Destroy the Ring',
        status => 'open',
        realm => 'europe' # FIXME - Middle-earth!
    } };

    # Regular Atom
    my $response = dancer_response GET => '/api/event/atom?realm=europe';
    is $response->status, 200;
    like $response->content, qr/Frodo joins Play Perl/;

    # Atom has filter.
    $response = dancer_response GET => '/api/event/atom?types=add-quest&realm=europe';
    is $response->status, 200;
    unlike $response->content, qr/Frodo joins Play Perl/;
}

__PACKAGE__->new->runtests;
