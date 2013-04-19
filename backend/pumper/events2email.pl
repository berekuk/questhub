#!/usr/bin/env perl
package bin::pumper::comments2email;

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

sub process_comment_add {
    my $self = shift;
    my ($event) = @_;

    my $item = $event->{object};
    my $quest = $item->{quest};

    my @recipients = (
        @{ $quest->{team} },
        ($quest->{watchers} ? @{ $quest->{watchers} } : ()),
    );
    my %_uniq_recipients = map { $_ => 1 } @recipients;
    @recipients = keys %_uniq_recipients;
    @recipients = grep { $_ ne $item->{author} } @recipients;

    my $body_html;
    for my $recipient (@recipients) {
        my $email = db->users->get_email($recipient, 'notify_comments') or next;

        $body_html ||= pp_markdown($item->{body});
        # TODO - quoting
        # TODO - unsubscribe link

        my $email_body_address;
        if (grep { $_ eq $recipient } @{ $quest->{team} }) {
            $email_body_address = "your quest";
        }
        else {
            $email_body_address = "the quest you're watching,";
        }
        my $email_body_header = '<a href="http://'.setting('hostport').qq[/player/$item->{author}">$item->{author}</a> commented on $email_body_address <a href="http://].setting('hostport').qq[/quest/$item->{quest_id}">$quest->{name}</a>:];
        my $email_body = qq[
            <p>
            $email_body_header
            <hr>
            </p>
            <p>$body_html</p>
        ];
        db->events->email(
            $email,
            "$item->{author} commented on '$quest->{name}'",
            $email_body,
        );
        $self->add_stat('emails sent');
    }
}

sub run_once {
    my $self = shift;

    while (my $item = $self->in->read) {
        $self->in->commit; # it's better to lose the email than to spam a user indefinitely
        if ($item->{object_type} eq 'comment' and $item->{action} eq 'add') {
            $self->process_comment_add($item);
        }

        $self->add_stat('events processed');
    }
}

__PACKAGE__->run_script;
