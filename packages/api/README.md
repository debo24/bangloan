# Bangloan API layer

## Run Locally

```bash
yarn dev
```

## Supabase Stop/Start

```bash
# start and initialize database
supabase start
```

```bash
# stop
supabase stop
```

```bash
# stop and clear database
supabase stop --no-backup
```

## API

### API Docs : http://localhost:3001/api/docs

1. To execute a script, create a User (via App or Script)
1. Authenticate using Swagger http://localhost:3001/api/docs#/Authentication
1. Click "Authorize" button and provide the bearer token from step #2

## Docker

## Build Docker Image

```bash
# build the docker file - --platform needs to match the fly.io instances.  currently linux/amd64.
docker build --platform linux/amd64 -f Dockerfile -t bangloan-local-api ../..

# list docker images
docker images
```

Docker Interactive shell, e.g. run `ls` to see image folder contents

```bash
docker run -it bangloan-local-api /bin/sh

# exit interactive shell
exit
```

## Run via Docker

```bash
# run docker
docker run -d -p 3001:3001 --name bangloan-local-container bangloan-local-api

## list running docker containers
docker ps

# view docker logs
docker logs bangloan-local-container
```

## Teardown

```bash
# stop the container
docker stop bangloan-local-container

# delete the container
docker rm bangloan-local-container

# delete the image
docker rmi bangloan-local-api
```
