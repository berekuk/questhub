use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);

sub setup :Test(setup) {
    reset_db();
}

sub add :Tests {
    my $stencil = db->stencils->add({
        realm => 'europe',
        author => 'foo',
        name => 'Start the World War I',
        points => 2,
    });
    my $stencil2 = db->stencils->add({
        realm => 'europe',
        author => 'foo',
        name => 'Start the World War II',
        description => 'Hitler Hitler Hitler Hitler.',
    });
    cmp_deeply $stencil, superhashof {
        realm => 'europe',
        name => 'Start the World War I',
        author => 'foo',
        _id => re('^\w{24}$'),
        ts => re('^\d+'),
        points => 2,
    };
}

sub list :Tests {
    db->stencils->add({
        realm => 'europe',
        author => 'foo',
        name => 'Start the World War I',
    });
    db->stencils->add({
        realm => 'europe',
        author => 'foo',
        name => 'Start the World War II',
        points => 3,
    });
    db->stencils->add({
        realm => 'asia',
        author => 'bar',
        name => 'Attack Pearl Harbor',
        points => 2,
    });

    my $stencils = db->stencils->list({});
    is scalar @$stencils, 3;
    cmp_deeply
        [ map { $_->{name} } @$stencils ],
        ["Start the World War I", "Attack Pearl Harbor", "Start the World War II"],
        'stencils are ordered by points score';

    $stencils = db->stencils->list({ realm => 'europe' });
    is scalar @$stencils, 2;
}

sub get :Tests {
    my $result = db->stencils->add({
        realm => 'europe',
        author => 'foo',
        name => 'Start the World War I',
    });

    my $stencil = db->stencils->get($result->{_id});
    cmp_deeply $stencil, superhashof {
        realm => 'europe',
        name => 'Start the World War I',
        author => 'foo',
        _id => re('^\w{24}$'),
        ts => re('^\d+'),
    };

    like
        exception { db->stencils->get('f' x 24) },
        qr/not found/;
}

sub take :Tests {
    db->users->add({ login => 'foo' });

    my $stencil = db->stencils->add({
        realm => 'europe',
        author => 'foo',
        name => 'Do something',
        description => 'Just do anything',
    });

    my $take_result = db->stencils->take($stencil->{_id}, 'foo');
    cmp_deeply $take_result, superhashof {
        team => ['foo'],
        name => 'Do something',
        note => 'Just do anything',
        realm => 'europe',
        stencil => $stencil->{_id},
        _id => $take_result->{_id},
    };

    my $quests = db->quests->list({ user => 'foo' });
    cmp_deeply $quests, [
        superhashof {
            team => ['foo'],
            name => 'Do something',
            note => 'Just do anything',
            realm => 'europe',
            stencil => $stencil->{_id},
            _id => $take_result->{_id},
        }
    ];
}

sub keeper_only :Tests {
    like exception {
        db->stencils->add({
            realm => 'europe',
            author => 'bar',
            name => 'Start the World War I',
        });
    }, qr/bar is not a keeper of europe/;
}

sub edit :Tests {
    my $stencil = db->stencils->add({
        realm => 'europe',
        author => 'foo',
        name => 'Start the World War I',
    });

    db->stencils->edit($stencil->{_id}, {
        name => 'Stop the World War I',
        user => 'foo2',
    });

    cmp_deeply
        db->stencils->get($stencil->{_id}),
        superhashof {
            name => 'Stop the World War I',
            author => 'foo',
        };

    like exception {
        db->stencils->edit($stencil->{_id}, {
            name => 'Stop the World War I',
            user => 'bar',
        });
    }, qr/access denied/;
}

sub points :Tests {
    like exception {
        db->stencils->add({
            realm => 'europe',
            author => 'foo',
            name => 'I want it all',
            points => 5,
        });
    }, qr/type constraint/;
}

__PACKAGE__->new->runtests;
