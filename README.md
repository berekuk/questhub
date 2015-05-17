# Questhub.io

http://questhub.io sources.

# Quick start

1. Install [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/).
2. Clone this repo.
3. Run `docker-compose up -d`.
(This step takes about half an hour on my laptop.)
4. Go to http://localhost:8000 in your browser.
(If you have issues with accessing the port, but `docker-compose ps` shows that everything is running, check out [Port forwarding](https://github.com/boot2docker/boot2docker/blob/master/doc/WORKAROUNDS.md#port-forwarding) instructions.)

# Development

## How everything is configured

Questhub consists of the following containers:

* `backend` with background jobs
* `app` with API server (written in Perl Dancer) serving JSON
* `frontend` with NGINX which proxies API requests to `app` and serves other files statically
* `www` with frontend JS code, webpack for development and some node modules
* also, `mongo` with MongoDB
* `data` with data volumes, mostly logs
* `dev` for the editing environment (tuned for berekuk's comfort, check out the Dockerfile)

Read `docker-compose.yml` for the details how all these are linked together.

Logs and other data, except for mongodb, is mounted to `data` via `data` container. Nginx logs are in `data/access.log` and `data/error.log`. Dancer logs are in `data/dancer`.

## How development is different from production

* code is mounted as volumes
* (app) dancer in development mode
* (www) generate JS code once instead of running webpack continously
* two app instances for potential zero-downtime deployment
* no SSL certificates

# Deployment

1. Prepare a new production host with `docker-machine` (check out `deploy/new-host.pl` for an example). Point your docker client to it.
2. Write `config/prod` based on `config/dev`.
3. Optionally, if you'd like to use SSL, put your SSL certificates to `/home/ubuntu/ssl` on the production server.
4. Run `docker-compose -f docker-compose.prod.yml up -d`.

# API

See `app/API.md` for backend API documentation.
