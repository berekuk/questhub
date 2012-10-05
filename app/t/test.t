use t::common;

# not logged in
{
    response_status_is [GET => '/api/quests'], 200, '/api/quests is public';
}

done_testing;
