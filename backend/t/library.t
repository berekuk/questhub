use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);

sub setup :Test(setup) {
    reset_db();
}

sub add :Tests {
    my $book = db->library->add({
        realm => 'europe',
        name => 'Start a World War I',
    });
    my $book2 = db->library->add({
        realm => 'europe',
        name => 'Start a World War II',
    });
    cmp_deeply $book, {
        realm => 'europe',
        name => 'Start a World War I',
        _id => re('^\w{24}$'),
        ts => re('^\d+'),
    };
}

sub list :Tests {
    db->library->add({
        realm => 'europe',
        name => 'Start a World War I',
    });
    db->library->add({
        realm => 'europe',
        name => 'Start a World War II',
    });
    db->library->add({
        realm => 'asia',
        name => 'Attach Pearl Harbor',
    });

    my $books = db->library->list({});
    is scalar @$books, 3;

    $books = db->library->list({ realm => 'europe' });
    is scalar @$books, 2;
}

__PACKAGE__->new->runtests;
