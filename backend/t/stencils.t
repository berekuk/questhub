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
        name => 'Start a World War I',
    });
    my $stencil2 = db->stencils->add({
        realm => 'europe',
        author => 'foo',
        name => 'Start a World War II',
    });
    cmp_deeply $stencil, {
        realm => 'europe',
        name => 'Start a World War I',
        author => 'foo',
        _id => re('^\w{24}$'),
        ts => re('^\d+'),
    };
}

sub list :Tests {
    db->stencils->add({
        realm => 'europe',
        author => 'foo',
        name => 'Start a World War I',
    });
    db->stencils->add({
        realm => 'europe',
        author => 'foo',
        name => 'Start a World War II',
    });
    db->stencils->add({
        realm => 'asia',
        author => 'foo',
        name => 'Attach Pearl Harbor',
    });

    my $stencils = db->stencils->list({});
    is scalar @$stencils, 3;

    $stencils = db->stencils->list({ realm => 'europe' });
    is scalar @$stencils, 2;
}

sub get :Tests {
    my $result = db->stencils->add({
        realm => 'europe',
        author => 'foo',
        name => 'Start a World War I',
    });

    my $stencil = db->stencils->get($result->{_id});
    cmp_deeply $stencil, {
        realm => 'europe',
        name => 'Start a World War I',
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
    });

    db->stencils->take($stencil->{_id}, 'foo');

    my $quests = db->quests->list({ user => 'foo' });
    cmp_deeply $quests, [
        superhashof {
            team => ['foo'],
            name => 'Do something',
            realm => 'europe',
        }
    ];
}

__PACKAGE__->new->runtests;
