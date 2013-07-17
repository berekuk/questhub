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

sub update_stat :Tests {
    db->users->add({ login => $_ }) for qw( foo bar baz zzz );
    db->users->join_realm(foo => 'europe');
    db->users->join_realm(bar => 'europe');
    db->users->join_realm(baz => 'europe');
    db->users->join_realm(baz => 'asia');
    db->users->join_realm(zzz => 'asia');

    cmp_deeply
        db->realms->get('europe'),
        superhashof {
            id => 'europe',
            stat => { users => 3 }
        };

    # db is already consistent, but we're checking that update_stat at least doesn't break anything
    # TODO - modify user.realms directly and then check that update_stat() fixes things
    db->realms->update_stat('europe');

    cmp_deeply
        db->realms->get('europe'),
        superhashof {
            id => 'europe',
            stat => { users => 3 }
        };
}

__PACKAGE__->new->runtests;
