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
    use Data::Dumper; print Dumper($events);
    template 'event-atom' => { events => $events };
};

true;
