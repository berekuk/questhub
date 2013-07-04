package Play::App::Util;

use Dancer ':syntax';

use parent qw(Exporter);
our @EXPORT_OK = qw( login try_login );

use Play::DB qw(db);

sub try_login {
    my $api_login = params->{api_login};
    my $api_token = params->{api_token};

    # api_login and api_token have a priority over session to simplify browser testing
    if ($api_login and $api_token) {
        my $settings = db->users->get_settings($api_login);
        unless ($settings->{api_token}) {
            die "$api_login needs to generate API token first";
        }
        unless ($settings->{api_token} eq $api_token) {
            die "Invalid token for user $api_login";
        }
        return $api_login;
    }

    return session->{login};
}

sub login {
    my $login = try_login;
    die "not logged in" unless $login;
    return $login;
}

1;
