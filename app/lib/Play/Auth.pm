package Play::Auth;

use Dancer ':syntax';
use Dancer::Plugin::Auth::Twitter;

use Play::Quests;
use Play::Mongo;

use Data::Dumper;
auth_twitter_init();

my $users = Play::Mongo->db->users;

prefix '/auth';

get '/twitter' => sub {
    if (not session('twitter_user')) {
        redirect auth_twitter_authenticate_url;
    } else {
        
        my $twitter_login = session->{twitter_user}->{screen_name};
        my $user = $users->find_one({twitter=>{login=>$twitter_login}});
        debug "found user!! ". Dumper($user);
        if ($user) {
            session 'login' => $user->{login};
        }
    	redirect "/";
    }
};

prefix '/api';


get '/user' => sub {
    if (request->params->{login}) {
         return { error => "TODO" };
    }
    if (request->params->{twitter_login}) {
         return { error => "TODO" };
    }
    
    my $login = session->{login};
    #TODO: cache in session
    my $user = $users->find_one({login => $login});
    return { 
        twitter => { login => $user->{twitter}->{login} },
        login => $user->{login},   
    };
};

get '/session' => sub {
    return {%{session()}};
};

get '/new_login' => sub {
    if (not session('twitter_user')) {
        return { error => "not authorized" };
    }
    my $twitter_login = session('twitter_user')->{screen_name};
    my $login = request->params->{login};
    if ($users->find_one({login => $login})) {
        return { error => "Already exists" };
    }
    if ($users->find_one({twitter=>{login => $twitter_login}})) {
        return { error => "Already bound" };
    }
    my $user = {login => $login, twitter => {login => $twitter_login}};
    session 'login' => $login;
    $users->insert($user);
    return { status => "ok", user => $user };
};

true;
