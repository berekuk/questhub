package Play::Route::Events;

use Dancer ':syntax';
prefix '/api';

use Play::Events;
my $events = Play::Events->new;

get '/event' => sub {
    return $events->list;
};

get '/event/atom' => sub {
    my $events = $events->list;
    header 'Content-Type' => 'application/xml';
    template 'event-atom' => { events => $events };
};

true;
