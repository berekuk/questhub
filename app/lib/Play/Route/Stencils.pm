package Play::Route::Stencils;

use Dancer ':syntax';
prefix '/api';

use Play::DB qw(db);
use Play::App::Util qw(login);

post '/stencil' => sub {
    my $login = login;

    my $params = {
        author => $login,
    };

    # optional fields
    for (qw/ description points /) {
        $params->{$_} = param($_) if defined param($_);
    };

    # required fields
    for (qw/ realm name /) {
        my $value = param($_) or die "'$_' is not set";
        $params->{$_} = $value;
    }

    return db->stencils->add($params);
};

get '/stencil' => sub {
    my $params = {
        map { param($_) ? ($_ => param($_)) : () } qw/ realm /,
    };
    $params->{quests} = 1; # TODO - param
    return db->stencils->list($params);
};

get '/stencil/:id' => sub {
    return db->stencils->get(param('id'), { quests => 1 });
};

put '/stencil/:id' => sub {
    my $login = login;

    my $params = {
        user => $login,
        map { defined(param($_)) ? ($_ => param($_)) : () } qw/ name description points /,
    };

    my $updated_id = db->stencils->edit(
        param('id'),
        $params
    );
    return { result => 'ok' };
};

post '/stencil/:id/take' => sub {
    my $login = login;

    my $result = db->stencils->take(param('id'), $login);
    return $result;
};

true;
