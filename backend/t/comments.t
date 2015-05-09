use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);

use Play::Types qw(Id);

sub setup :Test(setup) {
    reset_db();
}

sub add :Tests {
    db->users->add({ login => 'blah' });

    my $quest = db->quests->add({
        user => 'blah',
        name => 'foo',
        realm => 'europe',
    });
    my $quest_id = $quest->{_id};

    my $first = db->comments->add({ entity => 'quest', eid => $quest->{_id}, author => 'blah', body => 'first comment!' });
    my $second = db->comments->add({ entity => 'quest', eid => $quest->{_id}, author => 'blah', body => 'second comment!' });

    cmp_deeply
        $first,
        { _id => re('^\S+$') },
        'add comment result';

    my $list = db->comments->list('quest', $quest_id);
    cmp_deeply
        $list,
        [
            { _id => $first->{_id},  ts => re('^\d+$'), body => 'first comment!',  author => 'blah', entity => 'quest', eid => $quest_id, type => 'text' },
            { _id => $second->{_id}, ts => re('^\d+$'), body => 'second comment!', author => 'blah', entity => 'quest', eid => $quest_id, type => 'text' },
        ]
}

sub add_stencil_comment :Tests {
    db->users->add({ login => 'foo' });

    my $stencil = db->stencils->add({
        realm => 'europe',
        author => 'foo',
        name => 'sss',
        points => 2,
    });
    my $stencil_id = $stencil->{_id};

    my $comment = db->comments->add({ entity => 'stencil', eid => $stencil->{_id}, author => 'foo', body => 'first stencil comment ever!' });
    cmp_deeply
        $comment,
        { _id => re('^\S+$') },
        'add comment result';

    my $list = db->comments->list('stencil', $stencil_id);
    cmp_deeply
        $list,
        [
            { _id => $comment->{_id},  ts => re('^\d+$'), body => 'first stencil comment ever!',  author => 'foo', entity => 'stencil', eid => $stencil_id, type => 'text' },
        ]
}

sub list_respects_entity :Tests {
    db->users->add({ login => 'foo' });

    my $stencil = db->stencils->add({
        realm => 'europe',
        author => 'foo',
        name => 'sss',
        points => 2,
    });
    my $quest = db->quests->add({
        user => 'foo',
        name => 'foo',
        realm => 'europe',
    });

    my $quest_comment = db->comments->add({ entity => 'quest', eid => $quest->{_id}, author => 'foo', body => 'quest comment' });
    my $stencil_comment = db->comments->add({ entity => 'stencil', eid => $stencil->{_id}, author => 'foo', body => 'stencil comment' });

    cmp_deeply
        db->comments->list('quest', $quest->{_id}),
        [ superhashof({ _id => $quest_comment->{_id} }) ];

    cmp_deeply
        db->comments->list('stencil', $stencil->{_id}),
        [ superhashof({ _id => $stencil_comment->{_id} }) ];

    cmp_deeply
        db->comments->list('quest', $stencil->{_id}),
        [];

    cmp_deeply
        db->comments->list('stencil', $quest->{_id}),
        [];
}

sub bulk_get :Tests {
    db->users->add({ login => 'foo' });

    my $quest = db->quests->add({
        user => 'foo',
        name => 'q1',
        realm => 'europe',
    });
    my $quest_id = $quest->{_id};

    my @c = map {
        db->comments->add({ entity => 'quest', eid => $quest->{_id}, author => 'foo', body => "c$_" });
    } 0..4;

    my $comments = db->comments->bulk_get([ map { $_->{_id} } @c[0,2,3] ]);
    cmp_deeply $comments, {
        map {
            $c[$_]{_id} => superhashof({
                body => "c$_"
            })
        } (0,2,3)
    };
}

sub body2html :Tests {
    my ($html, $other) = db->comments->body2html('**bold**', 'europe');
    is
        $html,
        "<strong>bold</strong>\n",
        'basic markdown';
    cmp_deeply $other, { mentions => [] }, 'mentions are empty';


    ($html, $other) = db->comments->body2html('@berekuk, hello', 'europe');
    is
        $html,
        qq{<a href="http://localhost:8000/player/berekuk">berekuk</a>, hello\n},
        'expand @name';
    cmp_deeply $other, { mentions => ['berekuk'] }, 'mentions';

    ($html, $other) = db->comments->body2html('**bold**', 'europe');
    is
        $html,
        "<strong>bold</strong>\n",
        'basic markdown again';
    cmp_deeply $other, { mentions => [] }, 'mentions are reset';

}

sub bulk_count :Tests {
    db->users->add({ login => 'foo' });
    my $q1 = db->quests->add({
        user => 'foo',
        name => 'q1',
        realm => 'europe',
    });
    my $q2 = db->quests->add({
        user => 'foo',
        name => 'q2',
        realm => 'europe',
    });

    db->comments->add({ entity => 'quest', eid => $q1->{_id}, author => 'foo', body => "c1" });
    db->comments->add({ entity => 'quest', eid => $q1->{_id}, author => 'foo', body => "c2" });
    db->comments->add({ entity => 'quest', eid => $q2->{_id}, author => 'foo', body => "c3" });
    db->comments->add({ entity => 'quest', eid => $q1->{_id}, author => 'foo', type => 'close' });

    my $result = db->comments->bulk_count('quest', [ $q1->{_id}, $q2->{_id} ]);
    cmp_deeply(
        $result,
        {
            $q1->{_id} => 2,
            $q2->{_id} => 1,
        }
    );
}

sub add_secret :Tests {
    db->users->add({ login => 'blah' });

    my $quest = db->quests->add({
        user => 'blah',
        name => 'foo',
        realm => 'europe',
    });

    my $result = db->comments->add({
        entity => 'quest',
        eid => $quest->{_id},
        author => 'blah',
        type => 'secret',
        body => 'secret reward',
    });

    my $comment = db->comments->get_one($result->{_id});
    is $comment->{_id}, $result->{_id}, "got a secret comment";
    is $comment->{body}, undef, "secret comment has no body";
    ok Id->check($comment->{secret_id}), "secret comment 'secret_id' field";
}

sub reveal :Tests {
    db->users->add({ login => 'blah' });

    my $quest = db->quests->add({
        user => 'blah',
        name => 'foo',
        realm => 'europe',
    });

    my $text_result = db->comments->add({
        entity => 'quest',
        eid => $quest->{_id},
        author => 'blah',
        body => 'discuss',
    });
    my $secret_result = db->comments->add({
        entity => 'quest',
        eid => $quest->{_id},
        author => 'blah',
        type => 'secret',
        body => 'reward',
    });

    like exception {
        db->comments->reveal($text_result->{_id})
    }, qr/is not a secret comment/;

    db->comments->reveal($secret_result->{_id});

    my $revealed = db->comments->get_one($secret_result->{_id});
    is $revealed->{type}, 'secret', 'type is still "secret"';
    is $revealed->{body}, 'reward', 'comment body is visible';
    is $revealed->{secret_id}, undef, 'secret_id is unset after revealing';
}

__PACKAGE__->new->runtests;
