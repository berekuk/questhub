#!/usr/bin/env perl

use 5.012;
use warnings;
use lib '/play/backend/lib';

use Types::Standard qw(Dict Str);
use Type::Params qw(compile);

use autodie qw(open);
use Email::Simple;
use Email::Sender::Simple qw(sendmail);
use Encode qw(encode_utf8);

use Getopt::Long 2.33;
use Pod::Usage;

use Play::Config qw(setting);
use Play::DB qw(db);

sub load_targets {
    my @users = db->users->collection->find->all;

    my @targets;
    for my $user (@users) {
        my $login = $user->{login};
        # slower because we do an extra request per user, but at least we don't violate encapsulation
        my $email = db->users->get_email($login, 'newsletter') or next;
        push @targets, { login => $login, to => $email };
    }
    return @targets;
}

sub send_one {
    state $check = compile(Dict[
        title => Str,
        body => Str,
        login => Str,
        to => Str,
    ]);
    my ($params) = $check->(@_);
    my ($title, $body, $login, $to) = @$params{qw/ title body login to /};

    $body =~ s/{{login}}/$login/ or die "Login placeholder not found in newsletter";

    my $secret = db->users->unsubscribe_secret($login);
    my $unsubscribe_link = "http://".setting('hostport')."/api/user/$login/unsubscribe/newsletter?secret=$secret";

    $body =~ s/{{unsubscribe}}/$unsubscribe_link/ or die "Unsubscribe placeholder not found in newsletter";

    # TODO - send via sendmail queue
    # (need to support custom From in sendmail pumper first or decide that sending newsletter from notification@questhub.io is ok)
    my $email = Email::Simple->create(
        header => [
            To => $to,
            From => 'Vyacheslav Matyukhin <me@berekuk.ru>',
            Subject => $title,
            'Content-Type' => 'text/html; charset=utf-8',
        ],
        body => encode_utf8($body),
    );

    sendmail($email);
}

sub main {
    my $force;
    GetOptions(
        'f|force' => \$force,
    ) or pod2usage(2);

    state $check = compile(Str);
    my ($file) = $check->(@ARGV);

    open my $fh, '<', $file;

    my $title = <$fh>;
    chomp $title;
    $title =~ /questhub/i or die "Wrong title '$title'";

    my $newline = <$fh>;
    $newline eq "\n" or die "Expected second line to be empty";
    my $body = join '', <$fh>;

    $body =~ /{{login}}/ or die;
    $body =~ /{{unsubscribe}}/ or die;

    my @targets = load_targets();
    say "Sending newsletter to ".scalar(@targets)." users";

    @targets = grep { $_->{login} eq 'berekuk' } @targets unless $force;

    for my $target (@targets) {
        send_one({
            %$target,
            title => $title,
            body => $body,
        });
    }
}

main(@ARGV) unless caller;
