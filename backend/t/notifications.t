use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);
use Test::Fatal;

sub setup :Tests(setup) {
    reset_db();
}

sub add_and_list :Tests {

    db->users->add({ login => $_ }) for qw( foo bar );

    db->notifications->add('foo', 'shoutbox', { body => 'good news, everyone!' });
    db->notifications->add('bar', 'shoutbox', { body => 'good news, everyone!' });

    db->notifications->add('foo', 'shoutbox', { body => 'bad news, foo...' });

    my $list = db->notifications->list('foo');
    is scalar(@$list), 2;
    cmp_deeply $list, [
        superhashof({ user => 'foo' }),
        superhashof({ user => 'foo' }),
    ];
}

sub remove :Tests {

    my $id1 = db->notifications->add('foo', 'shoutbox', { body => 'one' });
    my $id2 = db->notifications->add('foo', 'shoutbox', { body => 'two' });
    my $id3 = db->notifications->add('foo', 'shoutbox', { body => 'three' });

    like exception { db->notifications->remove($id2, 'bar') }, qr/not found or access denied/;
    db->notifications->remove($id2, 'foo');
    my $list = db->notifications->list('foo');
    cmp_deeply $list, [
        superhashof({ params => { body => 'one' } }),
        superhashof({ params => { body => 'three' } }),
    ];
}

__PACKAGE__->new->runtests;
