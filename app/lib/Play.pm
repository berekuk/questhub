package Play;
use Dancer ':syntax';

our $VERSION = '0.1';

set serializer => 'JSON';

prefix '/api';

use Play::Quests;

my $quests = Play::Quests->new;

post '/quest/:id' => sub {
    $quests->update(
        param('id'),
        {
            user => 'fake',
            map { param($_) ? ($_ => param($_)) : () } qw/ name status /,
        }
    );
    return {
        ok => 1,
    }
};

post '/quest' => sub {
    $quests->add({
        user => 'fake',
        name => param('name'),
        status => 'open',
    });
    return {
        ok => 1,
    }
};

get '/quests' => sub {
    return $quests->list({
        map { param($_) ? ($_ => param($_)) : () } qw/ user status /,
    });
};

get '/quest/:id' => sub {
    return $quests->get(param('id'));
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
