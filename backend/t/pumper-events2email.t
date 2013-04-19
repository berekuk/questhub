use lib 'lib';
use Play::Test;
use Play::DB qw(db);

use Log::Any::Test;
use Log::Any qw($log);

my $pumper = pumper('events2email');

$pumper->run;
$log->empty_ok;

for (qw( foo bar baz baz2 )) {
    db->users->add({ login => $_ });
    db->users->set_settings($_ => { email => "$_\@example.com", notify_comments => 1 }, 1);
}

my $quest = db->quests->add({
    user => 'foo',
    name => 'foo quest',
    status => 'open',
});

subtest "non-comment event" => sub {
    $pumper->run;
    $log->contains_ok(qr/5 events processed/); # quest-add, user-add
};

my $email_in = Play::Flux->email->in('test');

subtest "comment on other user's quest" => sub {
    db->comments->add({ quest_id => $quest->{_id}, author => 'bar', body => '**strong**' });

    $pumper->run;
    $log->contains_ok(qr/1 emails sent, 1 events processed/);

    my $email = $email_in->read;
    $email_in->commit;
    like $email->[2], qr/commented on your quest/;

    is $email_in->read, undef;

    $log->clear;
};

subtest "comment on her own quest" => sub {
    db->comments->add({ quest_id => $quest->{_id}, author => 'foo', body => 'self-comment' });

    $pumper->run;
    $log->contains_ok(qr/1 events processed$/);

    is $email_in->lag, 0;

    $log->clear;
};

subtest "comment on watched quest" => sub {
    my $watched_quest = db->quests->add({
        user => 'bar',
        name => 'bar quest',
        status => 'open',
    });
    db->quests->watch($watched_quest->{_id}, 'baz');
    db->quests->watch($watched_quest->{_id}, 'baz2');

    db->comments->add({ quest_id => $watched_quest->{_id}, author => 'baz', body => 'preved!' });

    $pumper->run;
    $log->contains_ok(qr/2 emails sent, 2 events processed$/);

    my $chunk = $email_in->read_chunk(5);
    $email_in->commit;

    $chunk = [ sort { $a->[0] cmp $b->[0] } @$chunk ];
    is scalar @$chunk, 2;
    is $chunk->[0][0], 'bar@example.com';
    is $chunk->[1][0], 'baz2@example.com';

    like $chunk->[0][2], qr/commented on your quest/;
    unlike $chunk->[0][2], qr/commented on the quest you're watching/;

    unlike $chunk->[1][2], qr/commented on your quest/;
    like $chunk->[1][2], qr/commented on the quest you're watching/;
};

subtest "quest completed" => sub {
    my $q2 = db->quests->add({
        user => 'bar',
        name => 'bq2',
        status => 'open',
    });
    db->quests->watch($q2->{_id}, 'baz');
    db->quests->watch($q2->{_id}, 'baz2');

    db->quests->update($q2->{_id}, { status => 'closed', user => 'bar' });

    $pumper->run;
    $log->contains_ok(qr/2 emails sent, 2 events processed$/);

    my $chunk = $email_in->read_chunk(5);
    $email_in->commit;
    $chunk = [ sort { $a->[0] cmp $b->[0] } @$chunk ];
    is scalar @$chunk, 2;
    is $chunk->[0][0], 'baz2@example.com';
    is $chunk->[1][0], 'baz@example.com';

    like $chunk->[0][2], qr/completed a quest/;
    like $chunk->[1][2], qr/completed a quest/;
};

done_testing;
