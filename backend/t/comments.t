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

    my $first = db->comments->add({ quest_id => $quest->{_id}, author => 'blah', body => 'first comment!' });
    my $second = db->comments->add({ quest_id => $quest->{_id}, author => 'blah', body => 'second comment!' });

    cmp_deeply
        $first,
        { _id => re('^\S+$') },
        'add comment result';

    my $list = db->comments->get($quest->{_id});
    cmp_deeply
        $list,
        [
            { _id => $first->{_id}, ts => re('^\d+$'), body => 'first comment!', author => 'blah', quest_id => $quest_id },
            { _id => $second->{_id}, ts => re('^\d+$'), body => 'second comment!', author => 'blah', quest_id => $quest_id },
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
        db->comments->add({ quest_id => $quest->{_id}, author => 'foo', body => "c$_" });
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
    is
        db->comments->body2html({
            body => '**bold**',
            realm => 'europe',
        }),
        "<strong>bold</strong>\n",
        'basic markdown';

    is
        db->comments->body2html({
            body => '@berekuk, hello',
            realm => 'europe',
        }),
        qq{<a href="http://localhost:3000/europe/player/berekuk">berekuk</a>, hello\n},
        'expand @name';
}

__PACKAGE__->new->runtests;
