use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Scalar::Util qw(blessed);

use Play::EmailRecipients;

sub constructor :Tests {
    ok blessed(Play::EmailRecipients->new);
}

sub get_all_empty :Tests {
    cmp_deeply [ Play::EmailRecipients->new->get_all ], [];
}

sub basic :Tests {
    my $er = Play::EmailRecipients->new;
    $er->add_logins(['foo', 'bar', 'bar2'], 'team');
    $er->add_logins(['baz', 'bar'], 'watcher');
    $er->exclude('bar2');

    cmp_deeply
        [ sort { $a->{login} cmp $b->{login} } $er->get_all ],
        [
            { login => 'bar', reason => 'team' },
            { login => 'baz', reason => 'watcher' },
            { login => 'foo', reason => 'team' },
        ];
}

__PACKAGE__->new->runtests;
