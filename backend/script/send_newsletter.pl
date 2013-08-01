#!/usr/bin/env perl

=head1 SYNOPSIS

    send_newsletter.pl [--force] [--dump] [--campaign]

=cut

use 5.012;
use warnings;
use lib '/play/backend/lib';

use Types::Standard qw(Dict Str Bool);
use Type::Params qw(compile);

use autodie qw(open);
use Email::Simple;
use Play::Email;
use Encode qw(encode_utf8);
use MIME::Base64 qw(encode_base64);
use JSON;
use DateTime;

use Getopt::Long 2.33;
use Pod::Usage;

use Play::Config qw(setting);
use Play::DB qw(db);

sub load_targets {
    my @users = db->users->collection->find->all;
    say "Found ".scalar(@users)." users";

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
        dump => Bool,
        campaign => Str,
    ]);
    my ($params) = $check->(@_);
    my ($title, $body, $login, $to, $dump, $campaign) = @$params{qw/ title body login to dump campaign /};

    $body =~ s/{{login}}/$login/ or die "Login placeholder not found in newsletter";

    my $secret = db->users->unsubscribe_secret($login);
    my $unsubscribe_link = "http://".setting('hostport')."/api/user/$login/unsubscribe/newsletter?secret=$secret";

    $body =~ s/{{unsubscribe}}/$unsubscribe_link/ or die "Unsubscribe placeholder not found in newsletter";

    my $data = encode_base64(
        JSON->new->encode({
            event => 'open newsletter',
            properties => {
                distinct_id => $login,
                token => setting('mixpanel_token'),
                campaign => $campaign,
            },
        }),
        ''
    );
    $body .= qq{<img src="http://api.mixpanel.com/track/?data=$data&ip=1&img=1" width="1" height="1"/>};

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

    if ($dump) {
        use Data::Dumper;
        say Dumper $email;
        return;
    }
    Play::Email->sendmail($email);
}

sub main {
    my $force;
    my $dump;
    my $campaign;
    GetOptions(
        'f|force' => \$force,
        'd|dump' => \$dump,
        'c|campaign' => \$campaign,
    ) or pod2usage(2);

    unless ($campaign) {
        $campaign = lc(DateTime->today->month_name) . '-' . DateTime->today->day ;
        say "Campaign: $campaign";
    }

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
    my $total_number = @targets;

    @targets = grep { $_->{login} eq 'berekuk' } @targets unless $force;

    say "Sending newsletter to ".scalar(@targets)."/$total_number users";

    my $send_rate = 5;
    my $counter = 0;
    my $sent = 0;
    for my $target (@targets) {
        send_one({
            %$target,
            title => $title,
            body => $body,
            dump => $dump,
            campaign => $campaign,
        });
        $counter++;
        $sent++;
        if ($counter >= $send_rate) {
            $counter = 0;
            say "$sent/".scalar(@targets)." sent";
            sleep 1;
        }
    }
}

main(@ARGV) unless caller;
