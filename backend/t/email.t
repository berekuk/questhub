#!/usr/bin/perl

use 5.012;
use warnings;

use lib 'lib';
use parent qw(Test::Class);
use Test::More;
use Test::Fatal;

use Play::Email;
use Email::Simple;

sub send :Tests {
    like
        exception {
            Play::Email->send("abc")
        },
        qr/type constraint/,
        'send() expects Email::Simple';

    is
        exception {
            Play::Email->send(
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
        'send() expects Email::Simple';
}

__PACKAGE__->new->runtests;
