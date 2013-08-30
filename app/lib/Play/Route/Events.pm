package Play::Route::Events;

use Dancer ':syntax';
prefix '/api';

use DateTime;
use DateTime::Format::RFC3339;

use Play::DB qw(db);

use Play::Markdown qw(markdown);

my $rfc3339 = DateTime::Format::RFC3339->new;

get '/event' => sub {
    return db->events->list({
        map { param($_) ? ($_ => param($_)) : () } qw/ limit offset realm for author /,
    });
};

get '/event/atom' => sub {
    my @events = @{ db->events->list({
        limit => 30,
        map { param($_) ? ( $_ => param($_) ): () } qw/ realm limit for author /,
    })};

    for my $event (@events) {
        $event->{updated} = $rfc3339->format_datetime(
            DateTime->from_epoch(epoch => $event->{ts})
        );
    }

    header 'Content-Type' => 'application/xml';
    template 'event-atom' => {
        events => \@events,
        realm => param('realm'),
        for => param('for'),
        markdown => \&markdown,
    };
};

get '/feed' => sub {
    return db->events->feed({
        limit => 30,
        map { param($_) ? ( $_ => param($_) ): () } qw/ limit offset for realm /,
    });
};

true;
