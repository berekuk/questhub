#!/usr/bin/env perl
package bin::pumper::events2email;

use lib '/play/backend/lib';

use Moo;
use MooX::Options;
with 'Play::Pumper';

use Log::Any '$log';

use Play::Flux;
use Play::DB qw(db);
use Play::Config qw(setting);

has 'in' => (
    is => 'lazy',
    default => sub {
        return Play::Flux->events->in('/data/storage/events/events2email.pos');
    },
);

sub _quest2recipients {
    my $self = shift;
    my ($quest, $author) = @_;

    my @result;

    my @recipients = (
        @{ $quest->{team} },
        ($quest->{watchers} ? @{ $quest->{watchers} } : ()),
    );
    my %_uniq_recipients = map { $_ => 1 } @recipients;
    @recipients = keys %_uniq_recipients;
    @recipients = grep { $_ ne $author } @recipients;

    for my $recipient (@recipients) {
        my $email = db->users->get_email($recipient, 'notify_comments') or next;
        push @result, {
            email => $email,
            login => $recipient,
            reason => (
                scalar(grep { $_ eq $recipient } @{ $quest->{team} })
                ? 'team'
                : 'watcher'
            ),
        };
    }

    return @result;
}

sub process_add_comment {
    my $self = shift;
    my ($event) = @_;

    my $comment = $event->{comment};
    my $quest = $event->{quest};

    my @recipients = $self->_quest2recipients($quest, $comment->{author});
    return unless @recipients;

    my $body_html = db->comments->body2html($comment);

    for my $recipient (@recipients) {

        # TODO - quoting

        my $email_body_address;
        if ($recipient->{reason} eq 'team') {
            $email_body_address = "your quest";
        }
        else {
            $email_body_address = "the quest you're watching,";
        }
        my $email_body_header = '<a href="http://'.setting('hostport').qq[/player/$comment->{author}">$comment->{author}</a> commented on $email_body_address <a href="http://].setting('hostport').qq[/quest/$comment->{quest_id}">$quest->{name}</a>:];
        my $email_body = qq[
            <p>
            $email_body_header
            </p>
            <div style="margin-left: 20px">
            <p>$body_html</p>
            </div>
        ];
        db->events->email({
            address => $recipient->{email},
            subject => "$comment->{author} commented on '$quest->{name}'",
            body => $email_body,
            notify_field => 'notify_comments',
            login => $recipient->{login},
        });
        $self->add_stat('emails sent');
    }
}

sub process_close_quest {
    my $self = shift;
    my ($event) = @_;

    my $quest = $event->{quest};

    my @recipients = $self->_quest2recipients($quest, $event->{author});
    return unless @recipients;

    for my $recipient (@recipients) {
        my $email_body = qq[
            <p>
            <a href="http://].setting('hostport').qq[/player/$event->{author}">$event->{author}</a>
            completed a quest you're watching: <a href="http://].setting('hostport').qq[/quest/$event->{quest_id}">$quest->{name}</a>.
            </p>
        ];
        db->events->email({
            address => $recipient->{email},
            subject => "$event->{author} completed a quest: '$quest->{name}'",
            body => $email_body,
            notify_field => 'notify_comments', # TODO - invent another field?
            login => $recipient->{login},
        });
        $self->add_stat('emails sent');
    }
}

sub process_invite_quest {
    my $self = shift;
    my ($event) = @_;

    my $quest = $event->{quest};

    my $recipient = $event->{invitee};
    my $email = db->users->get_email($recipient, 'notify_invites') or return;

    {
        my $email_body = qq[
            <p>
            <a href="http://].setting('hostport').qq[/player/$event->{author}">$event->{author}</a>
            invited you to a quest: <a href="http://].setting('hostport').qq[/quest/$event->{quest_id}">$quest->{name}</a>.
            </p>
        ];
        db->events->email({
            address => $email,
            subject => "$event->{author} invites you to a quest: '$quest->{name}'",
            body => $email_body,
            notify_field => 'notify_invites',
            login => $recipient,
        });
        $self->add_stat('emails sent');
    }
}

sub run_once {
    my $self = shift;

    while (my $event = $self->in->read) {
        $self->in->commit; # it's better to lose the email than to spam a user indefinitely

        ($event) = @{ db->events->expand_events([$event]) };
        unless ($event) {
            $log->warn("Can't expand event (already deleted?)");
            next;
        }

        if ($event->{type} eq 'add-comment') {
            $self->process_add_comment($event);
        }
        if ($event->{type} eq 'close-quest') {
            $self->process_close_quest($event);
        }
        if ($event->{type} eq 'invite-quest') {
            $self->process_invite_quest($event);
        }

        $self->add_stat('events processed');
    }
}

__PACKAGE__->run_script;
