package Play::Route::Comments;

use Dancer ':syntax';
prefix '/api';

use Play::Comments;
my $comments = Play::Comments->new;

post '/quest/:quest_id/comment' => sub {
    die "not logged in" unless session->{login};
    my $id = $comments->add(
        quest_id => param('quest_id'),
        body => param('body'),
        author => session->{login},
    );
    return {
        _id => $id,
    }
};

get '/quest/:quest_id/comment' => sub {
    return $comments->get(param('quest_id'));
};

true;
