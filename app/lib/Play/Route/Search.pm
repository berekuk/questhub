package Play::Route::Search;

use Dancer ':syntax';
prefix '/api';

use Play::DB qw(db);

get '/search' => sub {
    return db->quests->search({
        query => param('q'),
    });
};

1;

