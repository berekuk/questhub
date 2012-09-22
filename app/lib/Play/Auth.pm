package Play::Auth;

use Dancer ':syntax';
use Dancer::Plugin::Auth::Twitter;

use Play::Quests;

auth_twitter_init();

prefix '/auth';

get 'twitter' => sub {
    if (not session('twitter_user')) {
        redirect auth_twitter_authenticate_url;
    }
    redirect "/";
};

get '/user' => sub {
    return { twitter => session('twitter_user') };
};


true;
