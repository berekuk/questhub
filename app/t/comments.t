use t::common;
use parent qw(Test::Class);

use Play::Quests;

sub setup :Tests(setup) {
    Dancer::session->destroy;
    for (qw/ quests comments users /) {
        Play::Mongo->db->$_->remove({});
    }
}

sub add_comment :Tests {

    Dancer::session login => 'blah';

    my $quest_result = http_json POST => '/api/quest', { params => { user => 'blah', name => 'foo', status => 'open' } };
    my $quest_id = $quest_result->{_id};

    my $first = http_json POST => "/api/quest/$quest_id/comment", { params => { body => 'first comment!' } };
    my $second = http_json POST => "/api/quest/$quest_id/comment", { params => { body => 'second comment!' } };

    cmp_deeply
        $first,
        { _id => re('^\S+$') },
        'add comment result';

    my $list = http_json GET => "/api/quest/$quest_id/comment";
    cmp_deeply
        $list,
        [
            { _id => $first->{_id}, body => 'first comment!', author => 'blah', quest_id => $quest_id },
            { _id => $second->{_id}, body => 'second comment!', author => 'blah', quest_id => $quest_id },
        ]
}

sub remove :Tests {

    Dancer::session login => 'blah';

    my $quest_result = http_json POST => '/api/quest', { params => { name => 'foo', status => 'open' } };
    my $quest_id = $quest_result->{_id};

    my $comment = http_json POST => "/api/quest/$quest_id/comment", { params => { body => "I'm just a little comment!" } };
    my $second_comment = http_json POST => "/api/quest/$quest_id/comment", { params => { body => "another one" } };

    Dancer::session login => 'other-user';
    my $response = dancer_response DELETE => "/api/quest/$quest_id/comment/$comment->{_id}";
    is $response->status, 500, "can't delete another user's comment";
    like decode_json($response->content)->{error}, qr/access denied/;

    my $comments = http_json GET => "/api/quest/$quest_id/comment";
    is scalar @$comments, 2;
    like $comments->[0]->{body}, qr/little comment/, 'comment still exists';

    Dancer::session login => 'blah';
    http_json DELETE => "/api/quest/$quest_id/comment/$comment->{_id}";

    $comments = http_json GET => "/api/quest/$quest_id/comment";
    is scalar @$comments, 1, 'comment really removed';
    like $comments->[0]->{body}, qr/another/, 'another comment still exists';
}

__PACKAGE__->new->runtests;
