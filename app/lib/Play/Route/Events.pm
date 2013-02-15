package Play::Route::Events;

use Dancer ':syntax';
prefix '/api';

use DateTime;
use DateTime::Format::RFC3339;

use Play::Events;
my $events = Play::Events->new;

my $rfc3339 = DateTime::Format::RFC3339->new;

get '/event' => sub {
    return $events->list;
};

get '/event/atom' => sub {
    my $events = $events->list;

    for my $event (@$events) {
        $event->{updated} = $rfc3339->format_datetime(
            DateTime->from_epoch(epoch => $event->{ts})
        );
    }

    header 'Content-Type' => 'application/xml';
    template 'event-atom' => { events => $events };
};

true;
