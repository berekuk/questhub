package Play::Route::Dev;

use Dancer ':syntax';
prefix '/api/dev';

get '/session/:name' => sub {
    my $name = param('name');
    return session($name);
};

true;
