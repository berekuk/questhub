package Play::Route::Quests;

use Dancer ':syntax';
prefix '/api';

use Play::Quests;
use Play::Users;
my $quests = Play::Quests->new;
my $users = Play::Users->new;

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

del '/quest/:id' => sub {
    die "not logged in" unless session->{login};
    $quests->remove(
        param('id'),
        { user => session->{login} }
    );
    return {
        result => 'ok',
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

for my $method (qw/ like unlike /) {
    post "/quest/:id/$method" => sub {
        die "not logged in" unless session->{login};
        $quests->$method(param('id'), session->{login});

        return {
            result => 'ok',
        }
    };
}

true;
