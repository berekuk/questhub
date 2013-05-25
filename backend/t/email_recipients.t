use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Scalar::Util qw(blessed);

use Play::DB qw(db);
use Play::EmailRecipients;

sub startup :Test(startup) {
    for (qw( foo bar baz baz2 xxx yyy zzz )) {
        db->users->add({ login => $_, realms => ['europe'] });
        db->users->set_settings($_ => {
                email => "$_\@example.com",
                notify_comments => 1,
                notify_invites => 1,
        }, 1);
    }
}

sub constructor :Tests {
    ok blessed(Play::EmailRecipients->new);
}

sub get_all_empty :Tests {
    cmp_deeply [ Play::EmailRecipients->new->get_all ], [];
}

sub composite :Tests {
    my $er = Play::EmailRecipients->new;
    $er->add_logins(['foo', 'bar', 'bar2'], 'team');
    $er->add_logins(['baz', 'bar'], 'watcher');
    $er->exclude('bar2');

    cmp_deeply
        [ sort { $a->{login} cmp $b->{login} } $er->get_all ],
        [
            { login => 'bar', email => 'bar@example.com', reason => 'team' },
            { login => 'baz', email => 'baz@example.com', reason => 'watcher' },
            { login => 'foo', email => 'foo@example.com', reason => 'team' },
        ];
}

sub priorities :Tests {
    my $er = Play::EmailRecipients->new;
    $er->add_logins(['foo'], 'team');
    $er->add_logins(['foo'], 'watcher');

    $er->add_logins(['bar'], 'watcher');
    $er->add_logins(['bar'], 'team');

    cmp_deeply
        [ sort { $a->{login} cmp $b->{login} } $er->get_all ],
        [
            superhashof({ login => 'bar', reason => 'team' }),
            superhashof({ login => 'foo', reason => 'team' }),
        ],
        'team overrides watcher independently of order',
}

sub exclude :Tests {
    my $er = Play::EmailRecipients->new;

    $er->add_logins(['foo', 'bar', 'baz'], 'team');
    $er->exclude('baz');

    cmp_deeply
        [ sort map { $_->{login} } $er->get_all ],
        [ 'bar', 'foo' ];
}

__PACKAGE__->new->runtests;
