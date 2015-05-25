#!/usr/bin/env python3

import re
import subprocess

def load_aws_credentials():
    content = subprocess.check_output('cat ~/.aws/credentials', shell=True, universal_newlines=True)
    access_key = re.search('aws_access_key_id = (.+)$', content, flags=re.MULTILINE).group(1)
    access_secret = re.search('aws_secret_access_key = (.+)$', content, flags=re.MULTILINE).group(1)
    return {
        'key': access_key,
        'secret': access_secret,
    }

def main():
    aws = load_aws_credentials()
    VPC = 'vpc-488dc52d' # berekuk's VPC
    subprocess.check_call([
        'docker-machine', 'create',
        '--driver', 'amazonec2',
        '--amazonec2-access-key', aws['key'],
        '--amazonec2-secret-key', aws['secret'],
        '--amazonec2-vpc-id', VPC,
        'questhub',
    ])


if __name__ == '__main__':
    main()
