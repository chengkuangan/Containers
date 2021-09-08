# MongoDB Container

This provides a MongoDB container with cluster feature enabled. It is intended to run as one instance cluster for demo purpose. The cluster feature is required to 
demonstrate transaction support for application container.

## To build the container

In the project root directory, run the following `docker` or `podman`

```
docker build -t chengkuan/opay/mongodb-5.0.2:latest .
```

```
podman build -t chengkuan/opay/mongodb-5.0.2:latest .
```

## Running container locally

1. Create a volume mapping for `/var/lib/mongodb` and run the container.

```
docker run -d --name mongodb --env MONGO_INITDB_ROOT_USERNAME=audit --env MONGO_INITDB_ROOT_PASSWORD=audit --env MONGODB_ADMIN_USER=audit --env MONGODB_ADMIN_PASSWORD=audit --env MONGODB_DATABASE=audit --mount source=mongo-data,target=/var/lib/mongodb -p 27017:27017 chengkuan/opay/mongodb-5.0.2:latest
```

```
podman run -d --name mongodb --env MONGO_INITDB_ROOT_USERNAME=audit --env MONGO_INITDB_ROOT_PASSWORD=audit --env MONGODB_ADMIN_USER=audit --env MONGODB_ADMIN_PASSWORD=audit --env MONGODB_DATABASE=audit --mount source=mongo-data,target=/var/lib/mongodb -p 27017:27017 chengkuan/opay/mongodb-5.0.2:latest
```

## Run the container in docker compose

```
  audit-mongodb:
    image: chengkuan/opay/mongodb-5.0.2:latest
    ports:
     - 27017:27017
    healthcheck:
      test: 'mongo localhost:27017/test --quiet'
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