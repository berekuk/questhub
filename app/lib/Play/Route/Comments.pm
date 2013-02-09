package Play::Route::Comments;

use Dancer ':syntax';
prefix '/api';

use Play::Comments;
my $comments = Play::Comments->new;

post '/quest/:quest_id/comment' => sub {
    die "not logged in" unless session->{login};
    return $comments->add(
        quest_id => param('quest_id'),
        body => param('body'),
        author => session->{login},
    );
};

get '/quest/:quest_id/comment' => sub {
    return $comments->get(param('quest_id'));
};

del '/quest/:quest_id/comment/:id' => sub {
    die "not logged in" unless session->{login};
    $comments->remove(
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
    $comments->update(
        quest_id => param('quest_id'),
        id => param('id'),
        body => param('body'),
        user => session->{login}
    );
    return {
        result => 'ok',
    }
};

true;
