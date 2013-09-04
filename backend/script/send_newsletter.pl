#!/usr/bin/env perl

=head1 SYNOPSIS

    send_newsletter.pl [--force] [--dump] [--campaign]

=cut

use 5.012;
use warnings;
use lib '/play/backend/lib';

use Types::Standard qw(Dict Str Bool);
use Type::Params qw(compile);
use Play::Types qw( Id Login );

use autodie qw(open);
use Email::MIME;
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
        push @targets, { login => $login, user_id => $user->{_id}->to_string, to => $email };
    }
    return @targets;
}

sub send_one {
    state $check = compile(Dict[
        title => Str,
        text_body => Str,
        html_body => Str,
        login => Login,
        user_id => Id,
        to => Str,
        dump => Bool,
        campaign => Str,
    ]);
    my ($params) = $check->(@_);
    my ($title, $text_body, $html_body, $login, $user_id, $to, $dump, $campaign) = @$params{qw/ title text_body html_body login user_id to dump campaign /};

    $_ =~ s/{{login}}/$login/ or die "Login placeholder not found in newsletter" for $text_body, $html_body;

    my $secret = db->users->unsubscribe_secret($login);
    my $unsubscribe_link = "http://".setting('hostport')."/api/user/$login/unsubscribe/newsletter?secret=$secret";

    $_ =~ s/{{unsubscribe}}/$unsubscribe_link/ or die "Unsubscribe placeholder not found in newsletter" for $text_body, $html_body;

    my $data = encode_base64(
        JSON->new->encode({
            event => 'open newsletter',
            properties => {
                distinct_id => $user_id,
                token => setting('mixpanel_token'),
                campaign => $campaign,
            },
        }),
        ''
    );
    $html_body .= qq{<img src="http://api.mixpanel.com/track/?data=$data&ip=1&img=1" width="1" height="1"/>};

    # TODO - send via sendmail queue
    # (need to support custom From in sendmail pumper first or decide that sending newsletter from notification@questhub.io is ok)
    my $email = Email::MIME->create(
        attributes => {
            content_type => 'multipart/alternative',
        },
        header_str => [
            From => 'Vyacheslav Matyukhin <me@berekuk.ru>',
            To => $to,
            Subject => $title,
        ],
        parts => [
            Email::MIME->create(
                attributes => { content_type => 'text/plain' },
                body => $text_body,
            ),
            Email::MIME->create(
                attributes => { content_type => 'text/html; charset=utf-8' },
                body => $html_body,
            )
        ],
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

    my ($text_body, $html_body) = split /__SPLIT__/, $body, 2 or die "No __SPLIT__ marker found";

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
            text_body => $text_body,
            html_body => $html_body,
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
