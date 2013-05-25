package Play::EmailRecipients;

use Moo;

use Play::DB qw(db);

use Types::Standard -types;
use Type::Params qw(validate);

has '_recipients' => (
    is => 'ro',
    isa => HashRef,
    default => sub { {} },
);

has 'reason2setting' => (
    is => 'ro',
    isa => HashRef,
    default => sub {
        {
            'team' => 'notify_comments',
            'watcher' => 'notify_comments',
            'mention' => 'notify_comments',
        };
    },
);

has 'priorities' => (
    is => 'ro',
    isa => ArrayRef[Str],
    default => sub {
        ['team', 'watcher', 'mention'];
    },
);

sub add_logins {
    my $self = shift;
    my ($logins, $reason) = validate(\@_, ArrayRef[Str], Str);

    my $recipients = $self->_recipients;
    for my $login (@$logins) {
        $recipients->{$login} ||= {
            login => $login,
            reasons => [],
        };
        push @{ $recipients->{$login}{reasons} }, $reason;
    }
    return;
}

sub exclude {
    my $self = shift;
    my ($login) = validate(\@_, Str);

    delete $self->_recipients->{$login};
    return;
}

sub get_all {
    my $self = shift;
    validate(\@_);

    my @result;
    my @recipients = values %{ $self->_recipients };

    my @priorities = @{ $self->priorities };
    my %reason2setting = %{ $self->reason2setting };

    for my $recipient (@recipients) {
        my $settings = db->users->get_settings($recipient->{login});
        next unless $settings->{email_confirmed};
        next unless $settings->{email};

        my @reasons = @{ $recipient->{reasons} };

        for my $reason (@priorities) {
            next unless grep { $_ eq $reason } @reasons;
            next unless $settings->{ $reason2setting{$reason} };

            push @result, {
                login => $recipient->{login},
                reason => $reason,
                email => $settings->{email},
                notify_field => $reason2setting{$reason},
            };
            last;
        }
    }

    return @result;
}

1;
