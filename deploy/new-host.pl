#!/usr/bin/env perl
use 5.016;
use warnings;

use IPC::System::Simple;
use autodie qw(:all);

sub xqx {
    my $command = join ' ', @_;
    my $result = qx($command);
    if ($?) {
        die "Command '$command' failed";
    }
    return $result;
}

sub aws_credentials {
    my $content = xqx("cat $ENV{HOME}/.aws/credentials");
    my ($access_key) = $content =~ /aws_access_key_id = (.+)$/m or die "Can't find an access key";
    my ($access_secret) = $content =~ /aws_secret_access_key = (.+)$/m or die "Can't find a secret access key";
    return {
        key => $access_key,
        secret => $access_secret,
    };
}

sub create_ec2_host {
    my $aws = aws_credentials();
    my $VPC = 'vpc-488dc52d'; # berekuk's VPC
    system(
        'docker-machine', 'create',
        '--driver', 'amazonec2',
        '--amazonec2-access-key', $aws->{key},
        '--amazonec2-secret-key', $aws->{secret},
        '--amazonec2-vpc-id', $VPC,
        'questhub',
    );
}

sub main {
    create_ec2_host();
}

main unless caller;
