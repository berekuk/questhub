package Play;
use Dancer ':syntax';

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get '/api/login' => sub {
    return {
        logged => '1',
        login => 'userlogin',
    };
};

true;
