package Play::Email;

use 5.012;
use warnings;

use Type::Params qw(compile);
use Type::Utils qw(class_type);

use Play::Config qw(setting);
use Email::Sender::Simple sendmail => { -as => 'email_sender_sendmail' };
use Email::Sender::Transport::SMTP::TLS;
use Email::Sender::Transport::DevNull;
use Email::Sender::Transport::Test;

sub _build_transport {
    if (setting('test')) {
        return Email::Sender::Transport::Test->new;
    }
    elsif (not setting('ses') or not setting('ses')->{username} or setting('ses')->{username} eq 'NONE') {
        return Email::Sender::Transport::DevNull->new;
    }
    return Email::Sender::Transport::SMTP::SSL->new(
        host => 'email-smtp.us-east-1.amazonaws.com',
        port => 587,
        username => setting('ses')->{username},
        password => setting('ses')->{password},
    );
}

sub transport {
    state $transport = _build_transport();
    return $transport;
}

sub sendmail {
    my $class = shift;
    state $check = compile(class_type { class => 'Email::Simple' });
    my ($email) = $check->(@_);

    return email_sender_sendmail($email, { transport => transport });
}

1;
