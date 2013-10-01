#!/usr/bin/env perl
package bin::pumper::events2email;

use lib '/play/backend/lib';

use Moo;
use MooX::Options;
with 'Play::Pumper';

use Log::Any '$log';

use Play::Flux;
use Play::DB qw(db);
use Play::WWW;

use Play::EmailRecipients;

has 'in' => (
    is => 'lazy',
    default => sub {
        return Play::Flux->events->in('/data/storage/events/events2email.pos');
    },
);

sub _object_url {
    my ($object, $entity) = @_;
    return Play::WWW->quest_url($object) if $entity eq 'quest';
    return Play::WWW->stencil_url($object) if $entity eq 'stencil';
    die "unknown entity '$entity'";
}

sub process_text_comment {
    my $self = shift;
    my ($event) = @_;

    my $comment = $event->{comment};
    my $object = $event->{ $comment->{entity} }; # expected entity to be either 'quest' or 'stencil'

    return unless $comment->{type} eq 'text'; # just a precaution, run_once() should filter other comments anyway

    my ($body_html, $markdown_extra) = db->comments->body2html($comment->{body}, $object->{realm});

    my @recipients;
    {
        my $er = Play::EmailRecipients->new;

        $er->add_logins($object->{team}, 'team') if $object->{team};
        $er->add_logins($object->{watchers}, 'watcher') if $object->{watchers};

        # TODO - should quest authors who left the team get emails too?
        $er->add_logins([ $object->{author} ], 'author') if $object->{author} and $comment->{entity} eq 'stencil';

        $er->add_logins($markdown_extra->{mentions}, 'mention') if $markdown_extra->{mentions};

        $er->exclude($comment->{author});

        @recipients = $er->get_all;
    }

    for my $recipient (@recipients) {

        # TODO - quote object name!

        my $reason = $recipient->{reason};

        my $appeal;
        if ($reason eq 'watcher') {
            $appeal = "commented on a $comment->{entity} you're watching,";
        }
        elsif ($reason eq 'mention') {
            $appeal = "mentioned you in a comment";
        }
        else {
            $appeal = "commented on your $comment->{entity}";
        }

        my $email_body_header =
            '<a href="' . Play::WWW->player_url($comment->{author}) . qq[">$comment->{author}</a> ]
            .$appeal.' <a href="' . _object_url($object, $comment->{entity}). qq[">$object->{name}</a>:];

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
            subject => "$comment->{author} commented on '$object->{name}'",
            body => $email_body,
            notify_field => $recipient->{notify_field},
            login => $recipient->{login},
        });
        $self->add_stat('emails sent');
    }
}

sub process_secret_comment {
    my $self = shift;
    my ($event) = @_;

    my $comment = $event->{comment};
    my $quest = $event->{quest};
    unless ($quest) {
        die "Didn't expect a secret comment on non-quest entity";
    }
    return unless $comment->{type} eq 'secret'; # just a precaution

    my @recipients;
    {
        my $er = Play::EmailRecipients->new;

        $er->add_logins($quest->{team}, 'team') if $quest->{team};
        $er->add_logins($quest->{watchers}, 'watcher') if $quest->{watchers};
        $er->exclude($comment->{author});

        @recipients = $er->get_all;
    }

    for my $recipient (@recipients) {
        my $email_body =
            '<p><a href="' . Play::WWW->player_url($comment->{author}) . qq[">$comment->{author}</a> ]
            . 'left a secret comment on <a href="' . _object_url($quest, 'quest'). qq[">$quest->{name}</a>.</p>];

        my $reason = $recipient->{reason};
        if ($reason eq 'watcher') {
            $email_body .= qq[
                <p>
                Wait until the quest is completed to find out what it says.
                </p>
            ];
        } else {
            $email_body .= qq[
                <p>
                Complete the quest to find out what it says!
                </p>
            ];
        }

        db->events->email({
            address => $recipient->{email},
            subject => "$comment->{author} left a secret comment on '$quest->{name}'",
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
            <a href="] . Play::WWW->player_url($event->{author}) . qq[">$event->{author}</a>
            completed a quest you're watching: <a href="]. _object_url($quest, 'quest') . qq[">$quest->{name}</a>.
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

sub process_clone_comment {
    my $self = shift;
    my ($event) = @_;

    my $quest = $event->{quest};

    my $recipient = $event->{comment}{invitee};
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
            <a href="] . Play::WWW->player_url($event->{author}) . qq[">$event->{author}</a>
            cloned a quest you're watching: <a href="] . _object_url($quest, 'quest') .qq[">$quest->{name}</a>.
            </p>
            <p>
            Cloned quest: <a href="] . _object_url($event->{comment}{cloned_to_object}, 'quest') .qq[">$event->{comment}{cloned_to_object}{name}</a>.
            </p>
        ];
        db->events->email({
            address => $recipient->{email},
            subject => "$event->{author} cloned a quest: '$quest->{name}'",
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

    my $recipient = $event->{comment}{invitee};
    my $email = db->users->get_email($recipient, 'notify_invites') or return;

    {
        my $email_body = qq[
            <p>
            <a href="] . Play::WWW->player_url($event->{author}) . qq[">$event->{author}</a>
            invited you to a quest: <a href="] . _object_url($quest, 'quest') .qq[">$quest->{name}</a>.
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
            if ($event->{comment}{type} eq 'text') {
                $self->process_text_comment($event);
            }
            elsif ($event->{comment}{type} eq 'close' and $event->{comment}{entity} eq 'quest') {
                $self->process_close_quest($event);
            }
            elsif ($event->{comment}{type} eq 'invite' and $event->{comment}{entity} eq 'quest') {
                $self->process_invite_quest($event);
            }
            elsif ($event->{comment}{type} eq 'secret') {
                $self->process_secret_comment($event);
            }
            elsif ($event->{comment}{type} eq 'clone') {
                $self->process_clone_comment($event);
            }
            # TODO - send emails on join, leave and other comment types
        }

        $self->add_stat('events processed');
    }
}

__PACKAGE__->run_script;
