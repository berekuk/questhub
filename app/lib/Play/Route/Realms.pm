package Play::Route::Quests;

use Dancer ':syntax';
prefix '/api';

use Play::DB qw(db);

get '/realm' => sub {
    return db->realms->list;
};

get '/realm/:id' => sub {
    return db->realms->get(param('id'));
};

true;
