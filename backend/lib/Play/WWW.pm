package Play::WWW;

use 5.012;
use warnings;

use Type::Params qw(compile);
use Types::Standard qw(HashRef Str Optional);
use Play::Types qw(Login);
use Type::Utils qw(enum);

use Play::Config qw(setting);

sub frontpage_url {
    my $class = shift;
    state $check = compile();
    $check->(@_);

    return "http://".setting('hostport');
}

sub player_url {
    my $class = shift;
    state $check = compile(Login);
    my ($login) = $check->(@_);

    return "http://".setting('hostport')."/player/$login";
}

sub quest_url {
    my $class = shift;
    state $check = compile(HashRef);
    my ($quest) = $check->(@_);

    return "http://".setting('hostport')."/realm/$quest->{realm}/quest/$quest->{_id}";
}

sub stencil_url {
    my $class = shift;
    state $check = compile(
        HashRef,
        Optional[enum('discuss')]
    );
    my ($stencil, $tab) = $check->(@_);

    my $url = "http://".setting('hostport')."/realm/$stencil->{realm}/stencil/$stencil->{_id}";
    $url .= "/$tab" if $tab;

    return $url;
}

sub confirm_email_url {
    my $class = shift;
    state $check = compile(Login, Str);
    my ($login, $secret) = @_;

    return "http://".setting('hostport')."/register/confirm/$login/$secret";
}

1;
