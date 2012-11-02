package Play::Route::Dev;

use Dancer ':syntax';
prefix '/api/dev';

if ($ENV{DEV_MODE}) {
    get '/session/:name' => sub {
        my $name = param('name');
        return session($name);
    };
}

true;
