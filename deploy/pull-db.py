#!/usr/bin/env python3

import argparse
import subprocess

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--production', action='store_true')
    parser.add_argument('--keep-settings', action='store_true')

    args = parser.parse_args()

    HOST = 'questhub.io'

    subprocess.check_call('docker exec -it questhub_backend_1 ./script/clear_mongo.sh', shell=True)
    subprocess.check_call('docker exec -it questhub_mongo_1 mongo play --eval "db.realms.drop()"', shell=True)
    subprocess.check_call('rm -rf dump', shell=True)
    subprocess.check_call('mkdir dump', shell=True)

    if args.production:
        subprocess.check_call([
            'ssh', 'ubuntu@{}'.format(HOST),
            "sh -c 'rm -rf dump && mongodump -d play'"
        ])
        subprocess.check_call([
            'scp', '-r', 'ubuntu@{}:dump/play'.format(HOST),
            './dump/play'
        ])
    else:
        backup_file = subprocess.check_output(
            'ls -t1 ~/Dropbox/backup/{} | head -1'.format(HOST),
            shell=True,
            universal_newlines=True,
        ).strip()
        subprocess.check_call('tar xfvz ~/dropbox/backup/{}/{}'.format(HOST, backup_file), shell=True)

    subprocess.check_call("tar -c dump | docker exec -i questhub_mongo_1 bash -c 'cd /data && rm -rf dump && tar -xv && cd dump && mongorestore --drop .'", shell=True)

    if not args.keep_settings:
        subprocess.check_call([
            'docker', 'exec', '-it', 'questhub_mongo_1',
            'mongo', 'play', '--eval', 'db.users.update({}, {"$unset": { "settings": 1 }}, false, true)'
        ])


if __name__ == '__main__':
    main()
