#!/usr/bin/perl
use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use autodie qw(system mkdir);

use Scalar::Util qw(blessed);

use Play::DB qw(db);
use Play::DB::Images;

use Play::Flux;

sub object :Tests {
    ok(
        blessed(db->images),
        'images is an object'
    );
}

sub upic :Tests {
    cmp_deeply(
        db->images->upic_default(),
        { small => ignore, normal => ignore }
    );

    cmp_deeply(
        db->images->upic_by_email('foo@example.com'),
        { small => ignore, normal => ignore }
    );

    cmp_deeply(
        db->images->upic_by_twitter_login('berekuk'),
        { small => ignore, normal => ignore }
    );
}

sub fetch :Tests {
    system 'rm -rf tfiles';
    mkdir 'tfiles';
    mkdir 'tfiles/storage';
    mkdir 'tfiles/storage/pic';
    my $images = Play::DB::Images->new(storage_dir => 'tfiles/storage');
    $images->fetch_upic(
        $images->upic_default,
        'berekuk'
    );

    ok -e 'tfiles/storage/pic/berekuk.small';

    is $images->upic_file('berekuk', 'small'), 'tfiles/storage/pic/berekuk.small';
    is $images->upic_file('berekuk', 'normal'), 'tfiles/storage/pic/berekuk.normal';
    is $images->upic_file('nazer', 'normal'), '/play/backend/pic/default/normal';
    like exception { db->images->upic_file('berekuk', 'blah') }, qr/type constraint/;
}

sub enqueue :Tests {
    db->images->enqueue_fetch_upic('berekuk', {
        small => 'http://example.com/small.jpg',
        normal => 'http://example.com/normal.jpg',
    });

    cmp_deeply(
        Play::Flux->upic->in('test')->read,
        {
            login => 'berekuk',
            upic => {
                small => 'http://example.com/small.jpg',
                normal => 'http://example.com/normal.jpg',
            },
        }
    );
}

__PACKAGE__->new->runtests;
