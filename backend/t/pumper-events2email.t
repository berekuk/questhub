use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::DB qw(db);

use Log::Any::Test;
use Log::Any qw($log);

my $pumper = pumper('events2email');
my $email_in = Play::Flux->email->in('test');
my $quest;

sub startup :Test(startup => 2) {
    $pumper->run;
    $log->empty_ok;

    for (qw( foo bar baz baz2 somebody somebody_else )) {
        db->users->add({ login => $_, realms => ['europe'] });
        db->users->set_settings($_ => {
                email => "$_\@example.com",
                notify_comments => 1,
                notify_invites => 1,
                notify_mentions => 1,
        }, 1);
    }

    $quest = db->quests->add({
        team => ['foo'],
        name => 'foo quest',
        status => 'open',
        realm => 'europe',
    });

    $pumper->run;
    $log->contains_ok(qr/7 events processed/); # quest-add, user-add
}

sub comment_on_other_users_quest :Tests {
    db->comments->add({ entity => 'quest', eid => $quest->{_id}, author => 'bar', body => '**strong**' });

    $pumper->run;
    $log->contains_ok(qr/1 emails sent, 1 events processed/);

    my $email = $email_in->read;
    $email_in->commit;
    like $email->{body}, qr/commented on your quest/;
    like $email->{body}, qr{"http://localhost:3000/europe/player/bar"};
    like $email->{body}, qr["http://localhost:3000/europe/quest/$quest->{_id}"];

    is $email_in->read, undef;

    $log->clear;
}

sub comment_on_your_own_quest :Tests {
    db->comments->add({ entity => 'quest', eid => $quest->{_id}, author => 'foo', body => 'self-comment' });

    $pumper->run;
    $log->contains_ok(qr/1 events processed$/);

    is $email_in->lag, 0;

    $log->clear;
}

sub comment_on_watched_quest :Tests {
    my $watched_quest = db->quests->add({
        team => ['bar'],
        name => 'bar quest',
        realm => 'europe',
    });
    db->quests->watch($watched_quest->{_id}, 'baz');
    db->quests->watch($watched_quest->{_id}, 'baz2');

    db->comments->add({ entity => 'quest', eid => $watched_quest->{_id}, author => 'baz', body => 'preved!' });

    $pumper->run;
    $log->contains_ok(qr/2 emails sent, 2 events processed$/);

    my $chunk = $email_in->read_chunk(5);
    $email_in->commit;

    $chunk = [ sort { $a->{address} cmp $b->{address} } @$chunk ];
    is scalar @$chunk, 2;
    is $chunk->[0]{address}, 'bar@example.com';
    is $chunk->[1]{address}, 'baz2@example.com';

    like $chunk->[0]{body}, qr/commented on your quest/;
    unlike $chunk->[0]{body}, qr/commented on a quest you're watching/;

    unlike $chunk->[1]{body}, qr/commented on your quest/;
    like $chunk->[1]{body}, qr/commented on a quest you're watching/;
}

sub comment_with_mentions :Tests {
    db->comments->add({
        entity => 'quest',
        eid => $quest->{_id},
        author => 'foo',
        body => '@somebody, @somebody_else, hello.'
    });

    $pumper->run;
    $log->contains_ok(qr/2 emails sent, 1 events processed$/);

    my $chunk = $email_in->read_chunk(5);
    $chunk = [ sort { $a->{address} cmp $b->{address} } @$chunk ];
    is scalar @$chunk, 2;
    is $chunk->[0]{address}, 'somebody@example.com';
    is $chunk->[1]{address}, 'somebody_else@example.com';

    like $chunk->[0]{body}, qr/mentioned you/;
    unlike $chunk->[0]{body}, qr/commented on your quest/;
    like $chunk->[1]{body}, qr/mentioned you/;
    unlike $chunk->[1]{body}, qr/commented on your quest/;
}

sub quest_completed :Tests {
    my $q2 = db->quests->add({
        team => ['bar'],
        name => 'bq2',
        status => 'open',
        realm => 'europe',
    });
    db->quests->watch($q2->{_id}, 'baz');
    db->quests->watch($q2->{_id}, 'baz2');

    db->quests->close($q2->{_id}, 'bar');

    $pumper->run;
    $log->contains_ok(qr/2 emails sent, 2 events processed$/);

    my $chunk = $email_in->read_chunk(5);
    $email_in->commit;
    $chunk = [ sort { $a->{address} cmp $b->{address} } @$chunk ];
    is scalar @$chunk, 2;
    is $chunk->[0]{address}, 'baz2@example.com';
    is $chunk->[1]{address}, 'baz@example.com';

    like $chunk->[0]{body}, qr/completed a quest/;
    like $chunk->[1]{body}, qr/completed a quest/;
}

sub invite :Tests {
    my $q2 = db->quests->add({
        team => ['bar'],
        name => 'bq3',
        status => 'open',
        realm => 'europe',
    });

    db->quests->invite($q2->{_id}, 'foo', 'bar');

    $pumper->run;
    $log->contains_ok(qr/1 emails sent, 2 events processed$/);

    my $chunk = $email_in->read_chunk(5);
    $email_in->commit;

    is $chunk->[0]{address}, 'foo@example.com';
    like $chunk->[0]{subject}, qr/bar invites you to a quest/;
};

__PACKAGE__->new->runtests;
