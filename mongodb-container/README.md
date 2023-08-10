# MongoDB Container

This MongoDB container build is used for Debezium Demo. When you starts the container for the first time, the startup script will create the necessary user and database configured via the standard environmental variables. Necessary user permissions are configured for this user. 

Once the user and database are created, a replicaset will be created.

Refer [Debezium Connector for MongoDB](https://debezium.io/documentation/reference/2.3/connectors/mongodb.html) for more detail of the neccesary pre-requisitions for configuring MongoDB for Debezium.

This container build is using the official [MongoDB container](https://hub.docker.com/_/mongo) image as the base image.

Current [Dockerfile](/mongodb-container/Dockerfile) is using `mongo:6.0.8`

## Environmental Variables

These are environmental variables to configure the database during startup:

- `MONGODB_ADMIN_USER` - Administrator username.
- `MONGODB_ADMIN_PASSWORD` - Administrator passwword
- `MONGODB_USER` - Username that will be used by Debezium
- `MONGODB_PASSWORD` - User password
- `MONGODB_DATABASE` - Database to be created for Debezium demo.

Refer [docker-compose.yaml](/mongodb-container/docker-compose.yaml) for a usage example.

## To build The Container

In the project root directory, run the following `docker` command

```
MONGODB_VERSION=6.0.8; docker buildx build \
--platform linux/arm64,linux/amd64 \
-t chengkuan/mongodb-arm64-${MONGODB_VERSION}:latest . \
--push
```

## Running the Container Locally Using Docker Compose

You can run and test the container locally using the provided [docker-compose.yaml](/mongodb-container/docker-compose.yaml) file.

At the project root directory:

```
docker compose up
```