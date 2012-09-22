package Play::Auth;

use Dancer ':syntax';
use Dancer::Plugin::Auth::Twitter;

use Play::Quests;

auth_twitter_init();

before sub {
    return if request->path =~ m{/auth/twitter/callback};
    if (not session('twitter_user')) {
        redirect auth_twitter_authenticate_url;
    }
};

prefix '/auth';

get '/user' => sub {
    return { twitter => session('twitter_user') };
};


true;
