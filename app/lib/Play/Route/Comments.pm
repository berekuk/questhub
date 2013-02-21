package Play::Route::Comments;

use Dancer ':syntax';
prefix '/api';

use Play::DB qw(db);

post '/quest/:quest_id/comment' => sub {
    die "not logged in" unless session->{login};
    return db->comments->add(
        quest_id => param('quest_id'),
        body => param('body'),
        author => session->{login},
    );
};

get '/quest/:quest_id/comment' => sub {
    return db->comments->get(param('quest_id'));
};

get '/quest/:quest_id/comment/:id' => sub {
    return db->comments->get_one(param('id'));
};

del '/quest/:quest_id/comment/:id' => sub {
    die "not logged in" unless session->{login};
    db->comments->remove(
        quest_id => param('quest_id'),
        id => param('id'),
        user => session->{login}
    );
    return {
        result => 'ok',
    }
};

put '/quest/:quest_id/comment/:id' => sub {
    die "not logged in" unless session->{login};
    my $updated_id = db->comments->update(
        quest_id => param('quest_id'),
        id => param('id'),
        body => param('body'),
        user => session->{login}
    );
    return {
        _id => $updated_id,
    }
};

true;
