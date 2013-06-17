package Play::Route::Quests;

use Dancer ':syntax';
prefix '/api';

use Play::DB qw(db);
use Play::Markdown qw(markdown);

use DateTime;
use DateTime::Format::RFC3339;
my $rfc3339 = DateTime::Format::RFC3339->new;

put '/quest/:id' => sub {
    die "not logged in" unless session->{login};
    my $updated_id = db->quests->update(
        param('id'),
        {
            user => session->{login},
            map { param($_) ? ($_ => param($_)) : () } qw/ name status tags description /,
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

    # optional fields
    my $params = {
        map { param($_) ? ($_ => param($_)) : () } qw/ tags description /,
    };

    # required fields
    for (qw/ realm name /) {
        my $value = param($_) or die "'$_' is not set";
        $params->{$_} = $value;
    }

    $params->{status} = 'open';
    $params->{team} = [ session->{login} ];

    return db->quests->add($params);
};

get '/quest' => sub {
    my $params = {
        map { param($_) ? ($_ => param($_)) : () } qw/ user status comment_count sort order limit offset tags watchers unclaimed realm /,
    };

    my $quests = db->quests->list($params);

    if (param('fmt') and param('fmt') eq 'atom') {
        die "realm not specified" unless param('realm');
        header 'Content-Type' => 'application/xml';

        my $frontend_url = '/';
        if (param('user')) {
            $frontend_url = '/'.param('realm').'/player/'.param('user');
        }
        elsif (param('tags')) {
            $frontend_url = '/'.param('realm').'/explore/latest/tag/'.param('tags');
        }

        my $atom_tag = join(',', map { "$_=$params->{$_}" } keys %$params);

        for my $quest (@$quests) {
            $quest->{updated} = $rfc3339->format_datetime(
                DateTime->from_epoch(epoch => $quest->{ts})
            );
        }

        template 'quest-atom' => {
            quests => $quests,
            params => $params,
            frontend_url => $frontend_url,
            atom_tag => $atom_tag,
            markdown => \&markdown,
        };
    }
    else {
        # default is json, as usual
        return $quests;
    }
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

for my $method (qw/ invite uninvite /) {
    post "/quest/:id/$method" => sub {
        die "not logged in" unless session->{login};
        db->quests->$method(param('id'), param('invitee'), session->{login});

        return {
            result => 'ok',
        }
    };
}

true;
