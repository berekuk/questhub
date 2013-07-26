use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);

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

    my $list = db->comments->get($quest->{_id});
    cmp_deeply
        $list,
        [
            { _id => $first->{_id},  ts => re('^\d+$'), body => 'first comment!',  author => 'blah', entity => 'quest', eid => $quest_id, type => 'text' },
            { _id => $second->{_id}, ts => re('^\d+$'), body => 'second comment!', author => 'blah', entity => 'quest', eid => $quest_id, type => 'text' },
        ]
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
        qq{<a href="http://localhost:3000/europe/player/berekuk">berekuk</a>, hello\n},
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

    my $result = db->comments->bulk_count([ $q1->{_id}, $q2->{_id} ]);
    cmp_deeply(
        $result,
        {
            $q1->{_id} => 2,
            $q2->{_id} => 1,
        }
    );
}

__PACKAGE__->new->runtests;
