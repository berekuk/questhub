package Play::Route::Dev;

use Dancer ':syntax';
prefix '/api/dev';

if ($ENV{QH_DEV}) {
    get '/session/:name' => sub {
        my $name = param('name');
        return session($name);
    };
}

true;
