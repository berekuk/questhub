package Play::Route::Events;

use Dancer ':syntax';
prefix '/api';

use Play::Events;
my $events = Play::Events->new;

get '/event' => sub {
    return $events->list;
};

true;
