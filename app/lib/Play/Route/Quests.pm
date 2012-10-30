package Play::Route::Quests;

use Dancer ':syntax';
prefix '/api';

use Play::Quests;
my $quests = Play::Quests->new;

put '/quest/:id' => sub {
    die "not logged in" unless session->{login};
    my $updated_id = $quests->update(
        param('id'),
        {
            user => session->{login},
            map { param($_) ? ($_ => param($_)) : () } qw/ name status /,
        }
    );
    return {
        result => 'ok',
        id => $updated_id,
    }
};

post '/quest' => sub {
    die "not logged in" unless session->{login};
    my $id = $quests->add({
        user => session->{login},
        name => param('name'),
        status => 'open',
    });
    return {
        result => 'ok',
        id => $id,
    }
};

get '/quests' => sub {
    return $quests->list({
        map { param($_) ? ($_ => param($_)) : () } qw/ user status /,
    });
};

get '/quest/:id' => sub {
    return $quests->get(param('id'));
};

true;
