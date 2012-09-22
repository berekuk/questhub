package Play;
use Dancer ':syntax';

our $VERSION = '0.1';

set serializer => 'JSON';

prefix '/api';

use Play::Quests;

my $quests = Play::Quests->new;

post '/quest/:id' => sub {
    $quests->update(
        param('id'),
        {
            user => 'fake',
            map { param($_) ? ($_ => param($_)) : () } qw/ name status /,
        }
    );
    return {
        ok => 1,
    }
};

post '/quest' => sub {
    $quests->add({
        user => 'fake',
        name => param('name'),
        status => 'open',
    });
    return {
        ok => 1,
    }
};

get '/quests' => sub {
    return $quests->list({
        map { param($_) ? ($_ => param($_)) : () } qw/ user status /,
    });
};

get '/quest/:id' => sub {
    return $quests->get(param('id'));
};

get '/api/login' => sub {
    return {
        logged => '1',
        login => 'userlogin',
    };
};

true;
