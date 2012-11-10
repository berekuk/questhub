use t::common;
use parent qw(Test::Class);

use Play::Users;

sub setup :Tests(setup) {
    Play::Users->new->collection->remove({});
    Dancer::session->destroy;
}

sub users_list_empty :Tests {
    my $users = http_json GET => '/api/users';
    cmp_deeply $users, [];
}

sub _add_users {
    for my $user (qw( blah blah2 )) {
        http_json GET => "/api/fakeuser/$user";
    }
}

sub current_user :Tests {
    my $self = shift;
    $self->_add_users;

    my $user = http_json GET => '/api/user';
    cmp_deeply $user, {
        "twitter" => {
            "screen_name" => 'blah2',
        },
        "_id" => re('\S+'),
        "login" => 'blah2',
        registered => 1,
    };
}

sub logout :Tests {
    my $self = shift;
    $self->_add_users;

    http_json post => '/api/logout';

    my $user = http_json get => '/api/user';
    cmp_deeply $user, { registered => 0 };
}

sub users_list :Tests {
    my $self = shift;
    $self->_add_users;

    my $user = http_json GET => '/api/users';
    cmp_deeply $user, [
        {
            "twitter" => {
                "login" => 'blah',
            },
            "_id" => re('\S+'),
            "login" => 'blah',
        },
        {
            "twitter" => {
                "login" => 'blah2',
            },
            "_id" => re('\S+'),
            "login" => 'blah2',
        },
    ];
}

__PACKAGE__->new->runtests;
