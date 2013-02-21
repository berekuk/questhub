package Play::Route::Users;

use Dancer ':syntax';

use Dancer::Plugin::Auth::Twitter;
auth_twitter_init();

use JSON;
use Play::DB qw(db);

get '/auth/twitter' => sub {
    if (not session('twitter_user')) {
        redirect auth_twitter_authenticate_url;
    } else {

        my $twitter_login = session('twitter_user')->{screen_name} or die "no twitter login in twitter_user session field";
        my $user = db->users->get_by_twitter_login($twitter_login);
        if ($user) {
            session 'login' => $user->{login};
        }
        redirect "/register";
    }
};

prefix '/api';

get '/current_user' => sub {

    my $user = {};
    my $login = session('login');
    if ($login) {
        $user = db->users->get_by_login($login);
        unless ($user) {
            die "user '$login' not found";
        }
        $user->{registered} = 1;

        $user->{settings} = db->users->get_settings($login);
    }
    else {
        $user->{registered} = 0;
    }

    if (session('twitter_user')) {
        $user->{twitter} = session('twitter_user');
    }

    return $user;
};

# user settings are private; you can't get settings of other users
get '/current_user/settings' => sub {
    my $login = session('login');
    die "not logged in" unless session->{login};
    return db->users->get_settings($login);
};

any ['put', 'post'] => '/current_user/settings' => sub {
    die "not logged in" unless session->{login};
    db->users->set_settings(
        session->{login} => scalar params()
    );
    return { result => 'ok' };
};

get '/user/:login' => sub {
    my $login = param('login');
    my $user = db->users->get_by_login($login);
    unless ($user) {
        die "user '$login' not found";
    }

    return $user;
};

post '/register' => sub {
    if (not session('twitter_user')) {
        die "not authorized";
    }
    my $twitter_login = session('twitter_user')->{screen_name};
    my $login = param('login') or die 'no login specified';

    if (db->users->get_by_login($login)) {
        die "User $login already exists";
    }
    if (db->users->get_by_twitter_login($twitter_login)) {
        die "Twitter login $twitter_login is already bound";
    }

    unless ($login =~ /^\w+$/) {
        status 'bad request';
        return "Invalid login '$login', only alphanumericals are allowed";
    }

    # note that race condition is still possible after these checks
    # that's ok, mongodb will throw an exception
    my $user = { login => $login, twitter => { screen_name => $twitter_login } };

    session 'login' => $login;
    db->users->add($user);

    my $settings = param('settings');
    if ($settings) {
        db->users->set_settings($login => decode_json($settings));
    }

    return { status => "ok", user => $user };
};

post '/register/resend_email_confirmation' => sub {
    my $login = session('login');
    die "not logged in" unless session->{login};
    db->users->resend_email_confirmation($login);
    return { result => 'ok' };
};

# user doesn't need to be logged to use this route
post '/register/confirm_email' => sub {
    # throws an exception if something's wrong
    db->users->confirm_email(param('login') => param('secret'));
    return { confirmed => 1 };
};

get '/user' => sub {
    return db->users->list({
        map { param($_) ? ($_ => param($_)) : () } qw/ sort order limit offset /,
    });
};

get '/user_count' => sub {
    my $count = scalar @{ db->users->list };
    return { count => $count };
};

post '/logout' => sub {

    session->destroy(session); #FIXME: workaround a buggy Dancer::Session::MongoDB

    return {
        status => 'ok'
    };
};

if ($ENV{DEV_MODE}) {
    get '/fakeuser/:login' => sub {
        my $login = param('login');
        session 'login' => $login;

        my $user = { login => $login };

        unless (param('notwitter')) {
            session 'twitter_user' => { screen_name => $login } unless param('notwitter');
            $user->{twitter} = { screen_name => $login };
        }

        db->users->add($user);
        return { status => 'ok', user => $user };
    };
}

true;
