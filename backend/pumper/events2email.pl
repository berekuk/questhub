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

use Text::Markdown qw(markdown);

sub pp_markdown {
    my ($body) = @_;
    my $html = markdown($body);
    $html =~ s{^<p>}{};
    $html =~ s{</p>$}{};
    return $html;
}

has 'in' => (
    is => 'lazy',
    default => sub {
        return Play::Flux->events->in('/data/storage/events/events2email.pos');
    },
);

sub _quest2recipients {
    my $self = shift;
    my ($quest, $author) = @_;

    my $result = {};

    my @recipients = (
        @{ $quest->{team} },
        ($quest->{watchers} ? @{ $quest->{watchers} } : ()),
    );
    my %_uniq_recipients = map { $_ => 1 } @recipients;
    @recipients = keys %_uniq_recipients;
    @recipients = grep { $_ ne $author } @recipients;

    for my $recipient (@recipients) {
        my $email = db->users->get_email($recipient, 'notify_comments') or next;
        if (grep { $_ eq $recipient } @{ $quest->{team} }) {
            $result->{$email} = 'team';
        }
        else {
            $result->{$email} = 'watcher';
        }
    }

    return $result;
}

sub process_add_comment {
    my $self = shift;
    my ($event) = @_;

    my $comment = $event->{comment};
    my $quest = $event->{quest};

    my $recipients = $self->_quest2recipients($quest, $comment->{author});
    return unless %$recipients;

    my $body_html = pp_markdown($comment->{body});

    for my $email (keys %$recipients) {

        # TODO - quoting
        # TODO - unsubscribe link

        my $email_body_address;
        if ($recipients->{$email} eq 'team') {
            $email_body_address = "your quest";
        }
        else {
            $email_body_address = "the quest you're watching,";
        }
        my $email_body_header = '<a href="http://'.setting('hostport').qq[/player/$comment->{author}">$comment->{author}</a> commented on $email_body_address <a href="http://].setting('hostport').qq[/quest/$comment->{quest_id}">$quest->{name}</a>:];
        my $email_body = qq[
            <p>
            $email_body_header
            <hr>
            </p>
            <p>$body_html</p>
        ];
        db->events->email(
            $email,
            "$comment->{author} commented on '$quest->{name}'",
            $email_body,
        );
        $self->add_stat('emails sent');
    }
}

sub process_close_quest {
    my $self = shift;
    my ($event) = @_;

    my $quest = $event->{quest};

    my $recipients = $self->_quest2recipients($quest, $event->{author});
    return unless %$recipients;

    for my $email (keys %$recipients) {
        my $email_body = qq[
            <p>
            <a href="http://].setting('hostport').qq[/player/$event->{author}">$event->{author}</a> completed a quest you're watching: <a href="http://].setting('hostport').qq[/quest/$event->{quest_id}">$quest->{name}</a>.];
        db->events->email(
            $email,
            "$event->{author} completed a quest: '$quest->{name}'",
            $email_body,
        );
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
            <a href="http://].setting('hostport').qq[/player/$event->{author}">$event->{author}</a> invited you to a quest: <a href="http://].setting('hostport').qq[/quest/$event->{quest_id}">$quest->{name}</a>.];
        db->events->email(
            $email,
            "$event->{author} invites you to a quest: '$quest->{name}'",
            $email_body,
        );
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
