package Play::Route::Events;

use Dancer ':syntax';
prefix '/api';

use DateTime;
use DateTime::Format::RFC3339;

use Play::DB qw(db);

my $rfc3339 = DateTime::Format::RFC3339->new;

get '/event' => sub {
    return db->events->list({
        map { param($_) ? ($_ => param($_)) : () } qw/ limit offset types/,
    });
};

get '/event/atom' => sub {
    my @events = @{ db->events->list };

    for my $event (@events) {
        $event->{updated} = $rfc3339->format_datetime(
            DateTime->from_epoch(epoch => $event->{ts})
        );
    }

    header 'Content-Type' => 'application/xml';
    template 'event-atom' => { events => \@events };
};

true;
