package Play::Route::Comments;

use Dancer ':syntax';
prefix '/api';

use Play::DB qw(db);
use Play::App::Util qw(login);

post '/quest/:quest_id/comment' => sub {
    my $login = login;

    return db->comments->add({
        entity => 'quest',
        eid => param('quest_id'),
        body => param('body'),
        author => $login,
    });
};

get '/quest/:quest_id/comment' => sub {
    return db->comments->list('quest', param('quest_id'));
};

get '/quest/:quest_id/comment/:id' => sub {
    return db->comments->get_one(param('id'));
};

del '/quest/:quest_id/comment/:id' => sub {
    my $login = login;
    db->comments->remove({
        id => param('id'),
        user => $login
    });
    return {
        result => 'ok',
    }
};

put '/quest/:quest_id/comment/:id' => sub {
    my $login = login;
    my $updated_id = db->comments->update({
        id => param('id'),
        body => param('body'),
        user => $login
    });
    return {
        _id => $updated_id,
    }
};

for my $method (qw/ like unlike /) {
    post "/quest/:quest_id/comment/:id/$method" => sub {
        my $login = login;
        db->comments->$method(param('id'), $login);

        return {
            result => 'ok',
        }
    };
}

true;
