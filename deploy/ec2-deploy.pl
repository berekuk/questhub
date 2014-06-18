#!/usr/bin/env perl

=head1 NAME

ec2-deploy.pl - deploy questhub.io code to Amazon EC2

=head1 SYNOPSIS

  ec2-deploy.pl [OPTIONS] NAME
    options:
      --create      Create the new instance
      --magic       Rebuild static and push code (can be dangerous, but automates my usual workflow)
      --provision   Provision with Chef cookbooks
      --no-restart  Don't restart Dancer backend

=head1 DESCRIPTION

Generally, only C<cpan:MMCLERIC> uses this script for deploying questhub.io to production. All other contributors should use local vagrant VM instead, as described in README.

=cut


use strict;
use warnings;
use 5.010;

use Getopt::Long 2.33;
use Pod::Usage;

use IPC::System::Simple;
use autodie qw(:all);

use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;

my %INSTANCES = (
    'questhub.io' => '54.225.128.184',
    'lw.questhub.io' => '184.72.252.27',
);
my $USER = 'ubuntu';

my $IP; # global variable, sorry;

sub xqx {
    my $command = join ' ', @_;
    my $result = qx($command);
    if ($?) {
        die "Command '$command' failed";
    }
    return $result;
}

sub INFO {
    say GREEN @_;
}

sub wait_for_bootstrap {
    INFO "Waiting for bootstrap to complete";
    for my $trial (1..40) {
        eval {
            system(qq{ssh -q -t $USER\@$IP "sudo -i which chef-solo > /dev/null"})
        };
        if ($@) {
            print '.';
            sleep 5;
            next;
        }
        INFO "chef-solo is ready";
        return;
    }
    print "\n";
    die "Timeout, check /var/log/user-data.log to find out why bootstrap.sh failed";
}

sub checkout_code {
    # we don't checkout it with chef because it's not in cookbooks, because sources and cookbooks are in a single repo...
    # maybe it's worth refactoring
    INFO 'Updating /play code';
    system(qq{ssh -t $USER\@$IP "sudo apt-get install git"});
    system(qq{ssh -t $USER\@$IP "sudo -i sh -c '[ -d /play ] || git clone https://github.com/berekuk/questhub.git /play'"});
    system(qq{ssh -t $USER\@$IP "sudo -i sh -c 'cd /play && git pull'"});
}

sub provision {
    INFO "Running chef-solo";
    system(qq{ssh -t $USER\@$IP "sudo -i sh -c 'chef-solo -c /tmp/cheftime/solo.rb -j /home/ubuntu/dna.json'"});
    INFO "Provisioning complete";
}

sub start_instance {
    INFO "Creating EC2 instance";
    my @command = ('ec2-run-instances',
        'ami-3d4ff254', # ubuntu 12.04
        '--instance-type', 't1.micro',
        '--user-data-file', 'deploy/files/bootstrap.sh',
        '--key', 'aws', # replace with your key pair name
    );
    my $result = xqx(@command);

    my ($instance) = $result =~ /^INSTANCE \s+ (i-\S+)/mx;
    INFO "Instance $instance created";
    sleep 3;

    system("ec2-associate-address -i $instance $IP");
    INFO "IP $IP associated with $instance";

    system("ssh-keygen -R $IP") if -e "$ENV{HOME}/.ssh/known_hosts";
    INFO "Old ssh host key removed";

    {
        my $ok;
        for my $trial (1..30) {
            my $key = xqx("ssh-keyscan $IP 2>/dev/null");
            chomp $key;
            unless ($key) {
                # too early
                print '.';
                sleep 3;
                next;
            }
            open my $fh, '>>', "$ENV{HOME}/.ssh/known_hosts";
            print {$fh} "$key\n";
            close $fh;
            $ok = 1;
            last;
        }
        die "Couldn't obtain ssh host key" unless $ok;
    }
    INFO "New ssh host key obtained";
}

sub check_local_repo {
    my $git_branch = qx(git rev-parse --abbrev-ref HEAD);
    chomp $git_branch;
    unless ($git_branch eq 'master') {
        die "Error: you should be on master branch to use --magic mode.\n";
    }

    my $git_status = qx(git status --short);
    chomp $git_status;
    if ($git_status) {
        die "You've got some uncommited files:\n$git_status\n";
    }
}

sub main {
    STDOUT->autoflush(1);

    my $create;
    my $provision;
    my $magic;
    my $restart = 1;
    GetOptions(
        'create!' => \$create,
        'p|provision!' => \$provision,
        'm|magic' => \$magic,
        'r|restart!' => \$restart,
    ) or pod2usage(2);

    pod2usage(2) unless @ARGV == 1 or @ARGV == 0;

    # there's only once instance now, but there were two, so why should I remove the perfectly working code?
    my $name = shift @ARGV;
    $name ||= 'questhub.io';

    $IP = $INSTANCES{$name} or die "Unknown instance '$name'";

    if ($magic) {
        check_local_repo();
        system('./build_static.pl');
        my $git_status = qx(git status --short);
        if ($git_status) {
            system('git add www-build');
            system("git commit -m 'rebuild static'");
            check_local_repo();
        }
        system('git push origin master');
        # TODO - run frontend and backend tests
        # TODO - compare the local git revision with remote and do nothing if they're equal
    }

    unless (-e "deploy/roles/$name.rb") {
        die "'deploy/roles/$name.rb' is missing!\n"; # instance roles are not commited to the repo, because they contain the secret twitter credentials
    }

    if ($create) {
        start_instance();
        wait_for_bootstrap();
        $provision = 1;
    }

    checkout_code();

    if ($provision) {
        system("scp deploy/roles/$name.rb $USER\@$IP:/home/ubuntu/ec2.rb");
        system("scp deploy/files/dna.json $USER\@$IP:.");
        system(qq{ssh -t $USER\@$IP "sudo -i sh -c 'mv /home/ubuntu/ec2.rb /play/roles/ec2.rb'"});
        provision();
    }

    system(qq{ssh -t $USER\@$IP "sudo ubic try-restart dancer"}) if $restart;
}

main unless caller;

=head1 SEE ALSO

This script is based on L<https://github.com/lynaghk/vagrant-ec2>.

=cut
