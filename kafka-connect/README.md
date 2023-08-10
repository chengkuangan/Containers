# Kafka Connect Container

This build of Kafka Connect container is for demo and development purposes. 

It is base on `quay.io/debezium/connect` and the MongoDB Kafka Connector plugin is added during the build.

Current [Dockerfile](/kafka-connect/Dockerfile) is using base image `quay.io/debezium/connect:2.3`

## Build the container image

Change directory to the project root and run the container build command. You change the MongoDB connector version by configuring the environmental variable `MONGODB_CONNECTOR_VERSION`.

Check the list of MongoDB Connector versions at this [MongoDB Kafka Connect Repo](https://repo1.maven.org/maven2/org/mongodb/kafka/mongo-kafka-connect)

```
export MONGODB_CONNECTOR_VERSION=1.9.1 && \
docker buildx build \
--platform linux/amd64,linux/arm64 \
-t chengkuan/kafka-connect-${CONTAINER_VERSION}:latest . \
--push
```

## Running the container

You need to have Apache Kafka and MongoDB running in the same network.

## Create Connector

Prepares your respective connector config and post this config to the connector

```
curl -X POST -H 'Content-Type: application/json' -d {CONNECTOR_CONFIG_JSON or JSON_FILE} http://localhost:8083/connectors
```