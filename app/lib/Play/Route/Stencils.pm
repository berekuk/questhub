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
    return db->stencils->list($params);
};

get '/stencil/:id' => sub {
    return db->stencils->get(param('id'));
};

post '/stencil/:id/take' => sub {
    my $login = login;

    db->stencils->take(param('id'), $login);
    return { result => 'ok' }; # TODO - return the id of newly created quest?
};

true;
