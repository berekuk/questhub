package Play::Route::Quests;

use Dancer ':syntax';
prefix '/api';

use Play::DB qw(db);

post '/library' => sub {
    my $login = login;

    my $params = {
        author => $login,
    };

    # required fields
    for (qw/ realm name /) {
        my $value = param($_) or die "'$_' is not set";
        $params->{$_} = $value;
    }

    return db->library->add($params);
};

get '/library' => sub {
    my $params = {
        map { param($_) ? ($_ => param($_)) : () } qw/ realm /,
    };
    return db->library->list($params);
};

get '/library/:id' => sub {
    return db->library->get(param('id'));
};

true;
