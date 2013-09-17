package Play::Route::Feeds;

use Dancer ':syntax';
prefix '/api';

use Play::DB qw(db);

get '/feed' => sub {
    return db->feeds->feed({
        limit => 30,
        map { param($_) ? ( $_ => param($_) ): () } qw/ limit offset for realm /,
    });
};

true;
