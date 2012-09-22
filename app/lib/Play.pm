package Play;
use Dancer ':syntax';

our $VERSION = '0.1';

set serializer => 'JSON';

prefix '/api';

use Play::Quests;
use Play::Auth;

my $quests = Play::Quests->new;

post '/quest/:id' => sub {
    die "not logged in" unless session->{login};
    my $updated_id = $quests->update(
        param('id'),
        {
            user => session->{login},
            map { param($_) ? ($_ => param($_)) : () } qw/ name status /,
        }
    );
    return {
        result => 'ok',
        id => $updated_id,
    }
};

post '/quest' => sub {
    die "not logged in" unless session->{login};
    $quests->add({
        user => session->{login},
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

    session->destroy(session); #FIXME: workaround a buggy Dancer::Session::MongoDB

    return {
        status => 'ok'
    };
};

true;
