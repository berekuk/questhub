#!/usr/bin/env perl
package bin::pumper::events2frf;

use lib '/play/backend/lib';

use Moo;
use MooX::Options;
with 'Play::Pumper';

use Log::Any '$log';

use Play::Flux;
use Play::DB qw(db);
use Play::Config qw(setting);

use LWP::UserAgent;

has 'in' => (
    is => 'lazy',
    default => sub {
        return Play::Flux->events->in('/data/storage/events/events2frf.pos');
    },
);

sub process_add_quest {
    my $self = shift;
    my ($event) = @_;

    my $settings = db->users->get_settings($event->{author});
    return unless $settings->{frf_remote_key} and $settings->{frf_username};

    my $quest = $event->{object};
    my $ua = LWP::UserAgent->new;
    $ua->credentials("friendfeed-api.com:80", "FriendFeed API", $settings->{frf_username}, $settings->{frf_remote_key});
    my $res = $ua->post("http://friendfeed-api.com/v2/entry", {
        body => $quest->{name},
        link => "http://".setting('hostport')."/quest/$event->{object_id}"
    });
    unless ($res->is_success) {
        $self->add_stat('failed to post');
        $log->warn("HTTP error: ".$res->status_line);
        return;
    }
    $self->add_stat('posted');
}

sub run_once {
    my $self = shift;

    while (my $event = $self->in->read) {
        $self->in->commit;
        if ($event->{object_type} eq 'quest' and $event->{action} eq 'add') {
            $self->process_add_quest($event);
        }

        $self->add_stat('events processed');
    }
}

__PACKAGE__->run_script;
