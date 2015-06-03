package Play::Email;

use 5.012;
use warnings;

use Type::Params qw(compile);
use Type::Utils qw(class_type);

use Play::Config qw(setting);
use Email::Sender::Simple sendmail => { -as => 'email_sender_sendmail' };
use Email::Sender::Transport::SMTP::TLS;
use Email::Sender::Transport::SMTP;
use Email::Sender::Transport::Test;

sub _build_transport {
    if (setting('test')) {
        return Email::Sender::Transport::Test->new;
    }
    elsif (not setting('aws') or not setting('aws')->{access_key_id} or setting('aws')->{access_key_id} eq 'NONE') {
        return Email::Sender::Transport::SMTP->new(
            host => 'localhost',
            port => 1025,
        );
    }

    return Email::Sender::Transport::SMTP::TLS->new(
        host => 'email-smtp.us-east-1.amazonaws.com',
        port => 587,
        username => setting('aws')->{access_key_id},
        password => setting('aws')->{secret_access_key},
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
