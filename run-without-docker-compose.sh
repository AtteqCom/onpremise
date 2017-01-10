#!/bin/sh

docker stop sentry-worker-01 sentry-web-01 sentry-cron
docker rm sentry-worker-01 sentry-web-01 sentry-cron

make build

REPOSITORY=sentry-onpremise

docker run --detach --name sentry-redis redis:3.2-alpine
docker run --detach --name sentry-postgres --env POSTGRES_PASSWORD=secretsentrypassword --env POSTGRES_USER=sentry postgres:9.5

SENTRY_SECRET_KEY=`docker run --rm ${REPOSITORY} config generate-secret-key`

docker run --link sentry-redis:redis --link sentry-postgres:postgres --env SENTRY_SECRET_KEY=${SENTRY_SECRET_KEY} --rm -it ${REPOSITORY} upgrade
docker run --link sentry-redis:redis --link sentry-postgres:postgres --env SENTRY_SECRET_KEY=${SENTRY_SECRET_KEY} --detach --name sentry-web-01 --publish 9000:9000 ${REPOSITORY} run web
docker run --link sentry-redis:redis --link sentry-postgres:postgres --env SENTRY_SECRET_KEY=${SENTRY_SECRET_KEY} --detach --name sentry-cron                       ${REPOSITORY} run cron
docker run --link sentry-redis:redis --link sentry-postgres:postgres --env SENTRY_SECRET_KEY=${SENTRY_SECRET_KEY} --detach --name sentry-worker-01                  ${REPOSITORY} run worker

