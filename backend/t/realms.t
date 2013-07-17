#!/usr/bin/perl
use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);
use Test::Fatal;

sub setup :Test(setup) {
    reset_db();
}

sub validate_name :Tests {
    ok not exception { db->realms->validate_name('europe') };
    ok exception { db->realms->validate_name('blah') };
}

sub list :Tests {
    cmp_deeply
        db->realms->list,
        [
            superhashof({ id => 'europe' }),
            superhashof({ id => 'asia' }),
        ];
}

sub add :Tests {
    db->realms->add({
        id => 'fitness',
        name => 'Fitness realm',
        description => 'Basically... run!',
        pic => 'none.png',
    });

    cmp_deeply
        db->realms->list,
        [
            superhashof({ id => 'europe' }),
            superhashof({ id => 'asia' }),
            superhashof({ id => 'fitness' }),
        ], 'new realm is there in ->list';

    like exception {
        db->realms->add({
            id => 'fitness',
            name => 'Fitness realm',
            description => 'Basically... run!',
            pic => 'none.png',
        });
    }, qr/dup key/, 'duplicate realm id is forbidden';

    is scalar @{ db->realms->list }, 3, 'duplicate realm not added';
}

sub update :Tests {
    db->realms->update('europe', {
        user => 'foo',
        name => 'Foo Land',
        description => 'Europe got conquered by Foo',
    });

    cmp_deeply
        db->realms->get('europe'),
        superhashof {
            id => 'europe',
            name => 'Foo Land',
            description => 'Europe got conquered by Foo',
            pic => 'europe.jpg',
            keepers => ['foo', 'foo2']
        },
        'update worked';

    like
        exception {
            db->realms->update('europe', {
                user => 'bar',
                name => 'Bar Land',
                description => 'I want to conquer Europe too!',
            });
        },
        qr/access denied/,
        'only keepers can update realms';
}

__PACKAGE__->new->runtests;
