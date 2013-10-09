package Play::Route::Search;

use Dancer ':syntax';
prefix '/api';

use Play::DB qw(db);

get '/search' => sub {
    my $params = {
        query => param('q'),
    };

    for (qw( limit offset )) {
        $params->{$_} = param($_) if defined param($_);
    }
    return db->quests->search($params);
};

1;

