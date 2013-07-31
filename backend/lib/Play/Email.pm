package Play::Email;

use 5.012;
use warnings;

use Type::Params qw(compile);
use Type::Utils qw(class_type);

use Play::Config qw(setting);

use Net::Amazon::SES;

sub _ses {
    state $ses = do {
        my $access_key = setting('aws')->{access_key};
        my $secret_key = setting('aws')->{secret_key};
        (
            $access_key eq 'NONE'
            ? undef
            : Net::Amazon::SES->new({
                AWSAccessKeyId => $access_key,
                AWSSecretKey => $secret_key,
            })
        )
    };
    return $ses;
}

sub send {
    my $class = shift;
    state $check = compile(class_type { class => 'Email::Simple' });
    my ($email) = $check->(@_);

    my $ses = _ses or return;
    $ses->send_msg({
        -msg => $email->as_string
    });
}

1;

