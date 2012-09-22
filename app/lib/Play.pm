package Play;
use Dancer ':syntax';

our $VERSION = '0.1';

set serializer => 'JSON';

prefix '/api';

use Play::Quests;

my $quests = Play::Quests->new;

get '/quest/list' => sub {
    return $quests->list('fake');
};

post '/quest/add' => sub {
    $quests->add({
        user => 'fake',
        name => param('description'),
        status => 'open',
    });
    return {
        ok => 1,
    }
};

true;
