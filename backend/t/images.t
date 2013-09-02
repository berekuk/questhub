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
        db->images->upic_by_twitter_data({ screen_name => 'berekuk', profile_image_url => 'http://example.com/normal.jpg' }),
        {
            small => 'http://example.com/mini.jpg',
            normal => 'http://example.com/normal.jpg',
        }
    );

    cmp_deeply(
        db->images->upic_by_twitter_data({ screen_name => 'berekuk', profile_image_url => 'http://example.com/normal' }),
        {
            small => 'http://example.com/mini',
            normal => 'http://example.com/normal',
        }
    );

    like(
        exception {
            db->images->upic_by_twitter_data({ screen_name => 'berekuk', profile_image_url => 'http://example.com/blah' })
        },
        qr/Unexpected twitter url/
    );
}

sub fetch :Tests {
    prepare_data_dir();

    db->images->fetch_upic(
        db->images->upic_default,
        'berekuk'
    );

    ok -e 'tfiles/images/pic/berekuk.small';

    is db->images->upic_file('berekuk', 'small'), 'tfiles/images/pic/berekuk.small';
    is db->images->upic_file('berekuk', 'normal'), 'tfiles/images/pic/berekuk.normal';
    is db->images->upic_file('nazer', 'normal'), '/play/backend/pic/default/normal';
    like exception { db->images->upic_file('berekuk', 'blah') }, qr/type constraint/;
}

sub fetch_schema :Tests {
    prepare_data_dir();

    like exception {
        db->images->fetch_upic(
            { normal => 'file://etc/passwd', small => 'file://etc/passwd' },
            'berekuk'
        );
    }, qr/Access to 'file' URIs has been disabled/;

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

sub store_upic_by_content :Tests {
    my $content = do { local (@ARGV, $/) = 'pic/default/normal'; <> };
    db->images->store_upic_by_content('foo', $content);

    ok -e 'tfiles/images/pic/foo.normal';
    ok -e 'tfiles/images/pic/foo.small';
    like qx(file tfiles/images/pic/foo.normal), qr/48 x 48/;
    like qx(file tfiles/images/pic/foo.small), qr/24 x 24/;
}

__PACKAGE__->new->runtests;
