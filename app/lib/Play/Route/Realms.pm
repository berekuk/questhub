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

put '/realm/:id' => sub {
    my $login = login;
    my $updated_id = db->realms->update(
        param('id'),
        {
            user => $login,
            map { defined(param($_)) ? ($_ => param($_)) : () } qw/ name description /,
        }
    );
    return { result => 'ok' };
};

true;
