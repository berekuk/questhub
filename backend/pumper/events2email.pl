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

use Play::EmailRecipients;

has 'in' => (
    is => 'lazy',
    default => sub {
        return Play::Flux->events->in('/data/storage/events/events2email.pos');
    },
);

sub process_add_comment {
    my $self = shift;
    my ($event) = @_;

    my $comment = $event->{comment};
    my $quest = $event->{quest};

    my ($body_html, $markdown_extra) = db->comments->body2html($comment->{body}, $quest->{realm});

    my @recipients;
    {
        my $er = Play::EmailRecipients->new;

        $er->add_logins($quest->{team}, 'team');
        $er->add_logins($quest->{watchers}, 'watcher') if $quest->{watchers};
        $er->add_logins($markdown_extra->{mentions}, 'mention') if $markdown_extra->{mentions};

        $er->exclude($comment->{author});

        @recipients = $er->get_all;
    }

    for my $recipient (@recipients) {

        # TODO - quote quest name!

        my $reason = $recipient->{reason};

        my $appeal;
        if ($reason eq 'watcher') {
            $appeal = "commented on a quest you're watching,";
        }
        elsif ($reason eq 'mention') {
            $appeal = "mentioned you in a quest";
        }
        else {
            $appeal = "commented on your quest";
        }
        my $email_body_header = '<a href="http://'.setting('hostport').qq[/player/$comment->{author}">$comment->{author}</a> $appeal <a href="http://].setting('hostport').qq[/quest/$comment->{quest_id}">$quest->{name}</a>:];
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
            notify_field => $recipient->{notify_field},
            login => $recipient->{login},
        });
        $self->add_stat('emails sent');
    }
}

sub process_close_quest {
    my $self = shift;
    my ($event) = @_;

    my $quest = $event->{quest};

    my @recipients;
    {
        my $er = Play::EmailRecipients->new;
        $er->add_logins($quest->{team}, 'team');
        $er->add_logins($quest->{watchers}, 'watcher') if $quest->{watchers};
        $er->exclude($event->{author});

        @recipients = $er->get_all;
    }

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
            notify_field => $recipient->{notify_field},
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
