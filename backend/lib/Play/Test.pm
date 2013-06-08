package Play::Test;

use 5.010;

use strict;
use warnings;

use parent qw(Exporter);
our @EXPORT = qw( reset_db pumper process_email_queue prepare_data_dir );

use Log::Any::Test;
use Import::Into;

use autodie qw(system);

BEGIN {
    $ENV{PLAY_CONFIG_FILE} = '/play/backend/t/data/config.yml';
    $ENV{EMAIL_SENDER_TRANSPORT} = 'Test';
}
use Email::Sender::Simple;

sub reset_db {
    for (qw/ quests comments users events notifications /) {
        Play::Mongo->db->get_collection($_)->remove({});
    }
}

sub pumper {
    my ($name) = @_;
    state $cache = {};
    unless ($cache->{$name}) {
        $cache->{$name} = (require "/play/backend/pumper/$name.pl")->new;
    }
    return $cache->{$name};
}

sub process_email_queue {

    Email::Sender::Simple->default_transport->clear_deliveries;
    my @t = Email::Sender::Simple->default_transport->deliveries;
    Play::Test::pumper('sendmail')->run;

    my @deliveries = Email::Sender::Simple->default_transport->deliveries;
    return @deliveries;
}

sub prepare_data_dir {
    system('rm -rf tfiles');
    system('mkdir -p tfiles/images/pic');
}

sub import {
    my $target = caller;

    require Test::More; Test::More->import::into($target, import => ['!pass']);
    require Test::Deep; Test::Deep->import::into($target, qw(cmp_deeply re superhashof ignore));
    require Test::Fatal; Test::Fatal->import::into($target);

    strict->import;
    warnings->import;
    utf8->import;

    use Play::DB qw(db);
    db->ensure_indices();
    reset_db();

    __PACKAGE__->export_to_level(1, @_);
}

1;
