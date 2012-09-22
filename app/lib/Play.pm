package Play;
use Dancer ':syntax';

our $VERSION = '0.1';

set serializer => 'JSON';

prefix '/api';

use Play::Quests;
use Play::Auth;

my $quests = Play::Quests->new;

get '/quest/list' => sub {
    return $quests->list('fake');
};

post '/quest/add' => sub {
    $quests->add({
        user => 'fake',
        name => param('description'),
        status => 'open',
    });
    return {
        ok => 1,
    }
};

get '/get_login' => sub {
    return {
        status => 'ok',
        logged => (defined session->{login} ? 1 : 0),
        login => session->{login},
    };
};

get '/logout' => sub {

    session->destroy;

    return {
        status => 'ok'
    };
};

get qr{/fakelogin/([\w]*)} => sub {

    my ($fakelogin) = splat;

    session login => $fakelogin;

    return {
        status => 'ok',
        fakelogin => $fakelogin,
    };
};

true;
