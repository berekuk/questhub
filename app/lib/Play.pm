package Play;
use Dancer ':syntax';
use Dancer::Plugin::Auth::Twitter;

our $VERSION = '0.1';

set serializer => 'JSON';

prefix '/api';

use Play::Quests;

auth_twitter_init();

before sub {
    if (not session('twitter_user')) {
        redirect auth_twitter_authenticate_url;
    }
};

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

get '/api/login' => sub {
    return {
        logged => '1',
        login => 'userlogin',
    };
};

get '/test/twitter' => sub {

    "welcome, ".session('twitter_user')->{'screen_name'};
};

true;
