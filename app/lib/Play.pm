package Play;
use Dancer ':syntax';

our $VERSION = '0.1';

set serializer => 'JSON';

prefix '/api';

use Play::Quests;

my $quests = Play::Quests->new;

post '/quest' => sub {
    $quests->add({
        user => 'fake',
        name => param('description'),
        status => 'open',
    });
    return {
        ok => 1,
    }
};

get '/quests' => sub {
    return $quests->list({
        user => 'fake'
    });
};

get '/quest/:id' => sub {
    return $quests->get({
        id => param('id')
    });
};

get '/api/login' => sub {
    return {
        logged => '1',
        login => 'userlogin',
    };
};

true;
