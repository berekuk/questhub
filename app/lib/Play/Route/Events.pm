package Play::Route::Events;

use Dancer ':syntax';
prefix '/api';

use DateTime;
use DateTime::Format::RFC3339;

use Play::DB qw(db);

use Text::Markdown qw(markdown);

my $rfc3339 = DateTime::Format::RFC3339->new;

# copy-pasted from backend/pumper/events2email.pl
sub _pp_markdown {
    my ($body) = @_;
    my $html = markdown($body);
    $html =~ s{^<p>}{};
    $html =~ s{</p>$}{};
    return $html;
}

get '/event' => sub {
    return db->events->list({
        map { param($_) ? ($_ => param($_)) : () } qw/ limit offset types realm for /,
    });
};

get '/event/atom' => sub {
    unless (param('realm') or param('for')) {
        status 'not_found';
        return "one of 'realm' or 'for' is necessary";
    }

    my @events = @{ db->events->list({
        limit => 30,
        map { param($_) ? ( $_ => param($_) ): () } qw/ types realm limit for /,
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
        markdown => \&_pp_markdown,
    };
};

true;
