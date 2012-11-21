package Play::Route::Comments;

use Dancer ':syntax';
prefix '/api';

use Play::Comments;
my $comments = Play::Comments->new;

post '/comment/:id' => sub {
    die "not logged in" unless session->{login};
    my $id = $comments->add(
        quest_id => param('id'),
        body => param('body'),
        author => session->{login},
    );
    return {
        result => 'ok',
        id => $id,
    }
};

get '/comments/:quest_id' => sub {
    return $comments->get(param('quest_id'));
};

true;
