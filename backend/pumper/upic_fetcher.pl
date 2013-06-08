#!/usr/bin/env perl
package bin::pumper::upic_fetcher;

use lib '/play/backend/lib';

use Moo;
use MooX::Options;
with 'Play::Pumper';

use Try::Tiny;
use Log::Any '$log';

use Play::DB qw(db);
use Play::Flux;

has 'in' => (
    is => 'lazy',
    default => sub { Play::Flux->upic->in('/data/storage/upic/pos') },
);

sub run_once {
    my $self = shift;

    while (my $item = $self->in->read) {

        try {
            db->images->fetch_upic($item->{upic}, $item->{login});
            $self->add_stat('ok');
        }
        catch {
            $log->warn("Failed to fetch upic for $item->{login}: $_");
            $self->add_stat('failed');
        };
        $self->in->commit;
    }
}

__PACKAGE__->run_script;
