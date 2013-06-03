#!/usr/bin/env perl

use lib '/play/backend/lib';
use Moo;
with 'Moo::Runnable';
use MooX::Options;

use Play::DB qw(db);

use Type::Params qw(validate);
use Types::Standard qw(Str);

option 'realm' => (
    is => 'ro',
    format => 's',
    required => 1,
);

sub run {
    my $self = shift;
    my $message = join '', <STDIN>;

    warn "realm: ".$self->realm;
    my $users = db->users->list({ realm => $self->realm });

    for my $user (@$users) {
        db->notifications->add($user->{login}, 'shout', $message);
    }
}

__PACKAGE__->run_script;
