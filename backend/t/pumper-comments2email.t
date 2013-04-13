#!/usr/bin/perl

use lib 'lib';
use Play::Test;
use Play::DB qw(db);

use Log::Any::Test;
use Log::Any qw($log);

my $pumper = pumper('comments2email');

$pumper->run;
$log->contains_ok(qr/0 comments processed/);
$log->clear;

db->users->add({ login => 'foo' });
db->users->add({ login => 'bar' });
my $quest = db->quests->add({
    user => 'foo',
    name => 'foo quest',
    status => 'open',
});

my $storage = Play::Flux->comments;
$storage->write({ quest_id => $quest->{_id}, author => 'bar', body => '**strong**' });
$storage->commit;

$pumper->run;
$log->contains_ok(qr/1 comments processed/);

done_testing;
