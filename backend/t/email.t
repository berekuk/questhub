use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::Email;
use Email::Simple;

sub sendmail :Tests {
    like
        exception {
            Play::Email->sendmail("abc")
        },
        qr/type constraint/,
        'sendmail() expects Email::Simple';

    is
        exception {
            Play::Email->sendmail(
                Email::Simple->create(
                    header => [
                        From => q[me@berekuk.ru],
                        To => q[me@berekuk.ru],
                        Subject => q[CLI test],
                    ],
                    body => q[CLI test body]
                )
            )
        },
        undef,
        'sendmail() expects Email::Simple';
}

sub transport :Tests {
    isa_ok(Play::Email->transport, 'Email::Sender::Transport::Test');
    # TODO - test that when test=0, transport is DevNull or SMTP::SSL
}

__PACKAGE__->new->runtests;
