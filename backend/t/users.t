use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);

sub setup :Test(setup) {
    reset_db();
}

sub join_realm :Tests {
    db->users->add({ login => 'foo', realms => ['europe'] });

    like
        exception { db->users->join_realm('foo', 'unknown') },
        qr/Unknown realm 'unknown'/;

    db->users->join_realm('foo', 'asia');

    my $user = db->users->get_by_login('foo');
    cmp_deeply $user->{realms}, ['europe', 'asia'];
    cmp_deeply $user->{rp}, { europe => 0, asia => 0 };

    like
        exception { db->users->join_realm('foo', 'asia') },
        qr/unable to join/;

}

sub follow_realm :Tests {
    db->users->add({ login => 'foo', realms => ['europe'] });

    like
        exception { db->users->follow_realm('foo', 'unknown') },
        qr/Unknown realm 'unknown'/;

    db->users->follow_realm('foo', 'asia');

    my $user = db->users->get_by_login('foo');
    cmp_deeply $user->{realms}, ['europe'];
    cmp_deeply $user->{rp}, { europe => 0 };
    cmp_deeply $user->{fr}, ['asia'];

    like
        exception { db->users->follow_realm('foo', 'asia') },
        qr/unable to follow/;

}

sub unsubscribe :Tests {
    db->users->add({ login => 'foo', realms => ['europe'] });

    db->users->set_settings(foo => {
        email => 'test@example.com',
        notify_likes => 1,
        notify_comments => 1,
    });

    like exception {
        db->users->unsubscribe({
            login => 'foo',
            notify_field => 'notify_likes',
            secret => '123',
        })
    }, qr/secret key is wrong/, 'unsubscribe requires a secret key';

    is db->users->get_settings('foo')->{notify_likes}, 1, 'notify_likes is still on';

    my $secret = db->users->unsubscribe_secret('foo');
    db->users->unsubscribe({
        login => 'foo',
        notify_field => 'notify_likes',
        secret => $secret,
    });

    is db->users->get_settings('foo')->{notify_likes}, 0, 'notify_likes is off';
}

sub get_by_twitter_login :Tests {
    db->users->add({
        login => 'foo',
        twitter => { screen_name => 'tfoo', profile_image_url => 'http://example.com/foo/normal' },
        realms => ['europe'],
    });

    cmp_deeply
        scalar(db->users->get_by_twitter_login('tfoo')),
        superhashof({
            login => 'foo',
        });
}

__PACKAGE__->new->runtests;
