#!/usr/bin/env python3

import argparse
import subprocess

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('host', nargs='?', default='questhub.io')

    args = parser.parse_args()
    host = args.host

    subprocess.check_call([
        'ssh', 'ubuntu@{}'.format(host),
        "sh -c 'rm -rf dump && rm -f backup.tar.gz && mongodump -d play && tar cfvz backup.tar.gz dump'"
    ])
    subprocess.check_call([
        'scp',
        'ubuntu@{}:backup.tar.gz'.format(host),
        '.'
    ])
    subprocess.check_call('mv backup.tar.gz ~/Dropbox/backup/' + host + '/$(date "+%Y-%m-%d").tar.gz', shell=True)

if __name__ == '__main__':
    main()
