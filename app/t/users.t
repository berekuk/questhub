use t::common;

{
    my $users = http_json GET => '/api/users';
    cmp_deeply $users, [];
}

for my $user (qw( blah blah2 )) {
    http_json GET => "/api/fakeuser/$user";
}

{
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

{
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

{
    http_json POST => '/api/logout';

    my $user = http_json GET => '/api/user';
    cmp_deeply $user, { registered => 0 };
}

done_testing;
