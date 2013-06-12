package Play::Route::Quests;

use Dancer ':syntax';
prefix '/api';

use Play::DB qw(db);

get '/realm' => sub {
    return db->realms->list;
};

true;
