# MongoDB Container

This provides a MongoDB container with cluster feature enabled. It is intended to run as one instance cluster for demo purpose. The cluster feature is required to 
demonstrate Debezium with replicatset. 

Using command line `mongosh`.

## To build the container

In the project root directory, run the following `docker`

Build `amd64` base container:

```

MONGODB_VERSION=6.0.8
docker buildx build \
--build-arg MONGODB_VERSION=${MONGODB_VERSION} \
--platform linux/amd64 \
-f Dockerfile.amd64 \
-t chengkuan/mongodb-amd64-${MONGODB_VERSION}:latest . \
--push
```

Build `arm64` base container:

```
MONGODB_VERSION=6.0.8
docker build \
--build-arg MONGODB_VERSION=${MONGODB_VERSION} \
--platform linux/arm64 \
-f Dockerfile.arm64 \
-t chengkuan/mongodb-arm64-${MONGODB_VERSION}:latest .

```

## Running container locally

1. Create a volume mapping for `/var/lib/mongodb` and run the container.

```
docker volume rm mongo-data && \
docker volume create mongo-data && \
docker run --rm --name mongodb --env MONGODB_USER=audit --env MONGODB_PASSWORD=audit --env MONGODB_ADMIN_USER=admin --env MONGODB_ADMIN_PASSWORD=admin --env MONGODB_DATABASE=audit --mount source=mongo-data,target=/var/lib/mongodb -p 27017:27017 chengkuan/mongodb-arm64-6.0.8:latest
```

## Run the container in docker compose

```
  audit-mongodb:
    image: chengkuan/opay/mongodb-arm64-6.0.8:latest
    ports:
     - 27017:27017
    healthcheck:
      test: 'mongosh localhost:27017/test --quiet'
      interval: 2s
      timeout: 20s
      retries: 10
    volumes:
      - /var/lib/mongodb
    environment:
     - MONGO_INITDB_ROOT_USERNAME=audit
     - MONGO_INITDB_ROOT_PASSWORD=audit
     - MONGODB_ADMIN_USER=audit
     - MONGODB_ADMIN_PASSWORD=audit
     - MONGODB_DATABASE=audit
```