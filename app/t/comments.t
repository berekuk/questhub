use t::common;
use parent qw(Test::Class);

sub add_comment :Tests {

    Dancer::session login => 'blah';

    my $quest_result = http_json POST => '/api/quest', { params => { user => 'blah', name => 'foo', status => 'open' } };
    my $quest_id = $quest_result->{id};

    my $first = http_json POST => "/api/comment/$quest_id", { params => { body => 'first comment!' } };
    my $second = http_json POST => "/api/comment/$quest_id", { params => { body => 'second comment!' } };

    cmp_deeply
        $first,
        { result => 'ok', id => re('^\S+$') },
        'add comment result';

    my $list = http_json GET => "/api/comment/$quest_id";
    cmp_deeply
        $list,
        [
            { _id => $first->{id}, body => 'first comment!', author => 'blah', quest_id => $quest_id },
            { _id => $second->{id}, body => 'second comment!', author => 'blah', quest_id => $quest_id },
        ]
}

__PACKAGE__->new->runtests;
