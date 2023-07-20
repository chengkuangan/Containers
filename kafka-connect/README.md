# Kafka Connect Container v1.0.0

Base on `quay.io/debezium/connect` and added MongoDB Kafka Connector plugin.

## Build the container image

Change directory to the project root and run the container build command:

```
export DEBEZIUM_VERSION=2.4 && \ 
export CONTAINER_VERSION=2.4 && \
export MONGODB_CONNECTOR_VERSION=1.9.1 && \
docker buildx build \
--platform linux/amd64,linux/arm64 \
-t chengkuan/kafka-connect-${CONTAINER_VERSION}:latest . \
--push
```

## Running the container

You need to have Apache Kafka running in the same network.

## Create Connector

Prepares your respective connector config and post this config to the connector

```
curl -X POST -H 'Content-Type: application/json' -d {CONNECTOR_CONFIG_JSON or JSON_FILE} http://localhost:8083/connectors
```