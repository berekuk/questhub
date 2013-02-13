use t::common;
use parent qw(Test::Class);

use Play::Quests;
use Email::Sender::Simple;

sub setup :Tests(setup) {
    Dancer::session->destroy;
    reset_db();
}

sub add_comment :Tests {

    Dancer::session login => 'blah';

    my $quest_result = http_json POST => '/api/quest', { params => { user => 'blah', name => 'foo', status => 'open' } };
    my $quest_id = $quest_result->{_id};

    my $first = http_json POST => "/api/quest/$quest_id/comment", { params => { body => 'first comment!' } };
    my $second = http_json POST => "/api/quest/$quest_id/comment", { params => { body => 'second comment!' } };

    cmp_deeply
        $first,
        { _id => re('^\S+$'), body_html => re('first') },
        'add comment result';

    my $list = http_json GET => "/api/quest/$quest_id/comment";
    cmp_deeply
        $list,
        [
            { _id => $first->{_id}, ts => re('^\d+$'), body => 'first comment!', author => 'blah', quest_id => $quest_id, body_html => re('first') },
            { _id => $second->{_id}, ts => re('^\d+$'), body => 'second comment!', author => 'blah', quest_id => $quest_id, body_html => re('second') },
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

sub body_html :Tests {
    Dancer::session login => 'blah';

    my $quest_result = http_json POST => '/api/quest', { params => { user => 'blah', name => 'foo', status => 'open' } };
    my $quest_id = $quest_result->{_id};

    my $body = 'To **boldly** go where no man has gone before';

    my $add_result = http_json POST => "/api/quest/$quest_id/comment", { params => { body => $body } };
    like $add_result->{body_html}, qr{To <strong>boldly</strong> go};

    my $comments = http_json GET => "/api/quest/$quest_id/comment";
    like $comments->[0]{body_html}, qr{To <strong>boldly</strong> go};
    is $comments->[0]{body}, $body;
}

sub comment_events :Tests {
    Dancer::session login => 'blah';

    my $quest_result = http_json POST => '/api/quest', { params => { user => 'blah', name => 'foo', status => 'open' } };
    my $quest_id = $quest_result->{_id};

    my $add_result = http_json POST => "/api/quest/$quest_id/comment", { params => { body => 'cbody, **bold cbody**' } };

    my $events = http_json GET => "/api/event";
    cmp_deeply $events->[0], {
        _id => re('^\S+$'),
        action => 'add',
        object_type => 'comment',
        object_id => $add_result->{_id},
        ts => re('^\d+$'),
        object => {
            author => 'blah',
            body => 'cbody, **bold cbody**',
            body_html => re('<strong>bold cbody</strong>'),
            quest => {
                _id => $quest_id,
                ts => re('^\d+'),
                name => 'foo',
                status => 'open',
                user => 'blah',
            },
            quest_id => $quest_id,
        },
    }, 'comment-add event';
}

sub perl_get_one :Tests {

    Dancer::session login => 'blah';

    my $quest_result = http_json POST => '/api/quest', { params => { user => 'blah', name => 'fff', status => 'open' } };
    my $quest_id = $quest_result->{_id};
    my $comment_result = http_json POST => "/api/quest/$quest_id/comment", { params => { body => "Blah" } };
    my $comment_id = $comment_result->{_id};

    my $comment = http_json GET => "/api/quest/$quest_id/comment/$comment_id";
    like $comment->{body}, qr/Blah/;
}

sub edit_comment :Tests {
    Dancer::session login => 'blah';

    my $quest_result = http_json POST => '/api/quest', { params => { user => 'blah', name => 'foo', status => 'open' } };
    my $quest_id = $quest_result->{_id};

    my $comment_result = http_json POST => "/api/quest/$quest_id/comment", { params => { body => "Commentin" } };
    my $comment_id = $comment_result->{_id};
    like $comment_id, qr/^\S+$/, 'comment id looks good';

    my $update_result = http_json PUT => "/api/quest/$quest_id/comment/$comment_id", { params => { body => "Commenting (fixed a typo)" } };
    my $comments = http_json GET => "/api/quest/$quest_id/comment";
    like $comments->[0]{body}, qr/fixed a typo/, 'comment body got updated';
}

sub email_comment :Tests {
    # 'foo' posts a quest, 'bar' comments on it

    http_json GET => "/api/fakeuser/foo";
    Dancer::session login => 'foo';

    register_email 'foo' => { email => 'test@example.com', notify_comments => 1, notify_likes => 0 };

    my $quest_result = http_json POST => '/api/quest', { params => { user => 'blah', name => 'foo-quest', status => 'open' } };
    my $quest_id = $quest_result->{_id};

    http_json GET => "/api/fakeuser/bar";
    Dancer::session login => 'bar';
    http_json POST => "/api/quest/$quest_id/comment", { params => { body => "Hello sweetie." } };

    my @deliveries = Email::Sender::Simple->default_transport->deliveries;
    is scalar(@deliveries), 1, '1 email sent';
    cmp_deeply $deliveries[0]{envelope}, {
        from => 'notification@play-perl.org',
        to => [ 'test@example.com' ],
    }, 'from & to addresses';
}

__PACKAGE__->new->runtests;
