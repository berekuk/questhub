#!/usr/bin/perl

use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);
use Play::Flux;

use Log::Any qw($log);

sub startup :Test(startup) {
    my $self = shift;
    $self->{pumper} = pumper('upic_fetcher');
}

sub setup :Test(setup) {
    prepare_data_dir();
}

sub teardown :Test(teardown) {
    $log->clear;
}

sub empty :Tests {
    my $self = shift;
    $self->{pumper}->run;
    $log->empty_ok;
}

sub one_pic :Tests {
    my $self = shift;

    db->images->enqueue_fetch_upic(
        'berekuk',
        {
            small => "http://www.gravatar.com/avatar/00000000000000000000000000000000?s=24",
            normal => "http://www.gravatar.com/avatar/00000000000000000000000000000000?s=48",
        }
    );
    $self->{pumper}->run;

    is db->images->upic_file('berekuk', 'small'), 'tfiles/images/pic/berekuk.small';
    is db->images->upic_file('berekuk', 'normal'), 'tfiles/images/pic/berekuk.normal';
    ok -e 'tfiles/images/pic/berekuk.small';
    ok -e 'tfiles/images/pic/berekuk.normal';

    $log->contains_ok(qr/1 ok/);

    $log->clear;
    $self->{pumper}->run;
    $log->empty_ok; # make sure that pumper commits its input stream
}

sub invalid_pic :Tests {
    my $self = shift;

    db->images->enqueue_fetch_upic(
        'bessarabov',
        {
            small => "file://etc/passwd",
            normal => "file://etc/passwd",
        }
    );
    db->images->enqueue_fetch_upic(
        'neilb',
        {
            small => "http://www.gravatar.com/avatar/00000000000000000000000000000000?s=24",
            normal => "http://www.gravatar.com/avatar/00000000000000000000000000000000?s=48",
        }
    );
    $self->{pumper}->run;

    $log->contains_ok(qr/1 failed, 1 ok/);

    is db->images->upic_file('neilb', 'small'), 'tfiles/images/pic/neilb.small';
    is db->images->upic_file('neilb', 'normal'), 'tfiles/images/pic/neilb.normal';
    ok -e 'tfiles/images/pic/neilb.small';
    ok -e 'tfiles/images/pic/neilb.normal';

    $log->clear;
    $self->{pumper}->run;
    $log->empty_ok; # make sure that pumper commits its input stream
}

__PACKAGE__->new->runtests;
