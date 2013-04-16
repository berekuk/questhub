package Play::Route::Quests;

use Dancer ':syntax';
use Play::DB qw(db);

prefix '/api';

put '/quest/:id' => sub {
    die "not logged in" unless session->{login};
    my $updated_id = db->quests->update(
        param('id'),
        {
            user => session->{login},
            map { param($_) ? ($_ => param($_)) : () } qw/ name status type tags /, # type is deprecated, TODO - remove
        }
    );
    return {
        _id => $updated_id,
    }
};

del '/quest/:id' => sub {
    die "not logged in" unless session->{login};
    db->quests->remove(
        param('id'),
        { user => session->{login} }
    );
    return {
        result => 'ok',
    }
};

post '/quest' => sub {
    die "not logged in" unless session->{login};

    my $attributes = {
        user => session->{login},
        name => param('name'),
        status => 'open',
        (param('tags') ? (tags => param('tags')) : ()),
    };
    return db->quests->add($attributes);
};

get '/quest' => sub {
    my $params = {
        map { param($_) ? ($_ => param($_)) : () } qw/ user status comment_count sort order limit offset tags watcher /,
    };
    if (param('unclaimed')) {
        $params->{user} = '';
    }

    return db->quests->list($params);
};

get '/quest/:id' => sub {
    return db->quests->get(param('id'));
};

for my $method (qw/ like unlike join leave watch unwatch /) {
    post "/quest/:id/$method" => sub {
        die "not logged in" unless session->{login};
        db->quests->$method(param('id'), session->{login});

        return {
            result => 'ok',
        }
    };
}

true;
