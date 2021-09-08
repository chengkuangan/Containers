# Kafka Connect Container v1.0.0

Provide definition to build Kafka Connect Container Image.

The connector plugins included in this build:

- Debezium Postgres connector version 1.6.1.Final
- Debezium Scripting version 1.3.1.Final
- MongoDB Connector version 1.6.1

## Build the container image

Change directory to the project root and run the container build command:

```
docker build -t chengkuan/opay/kafka-connect-1.6.1.final:latest .
```

```
podman build -t chengkuan/opay/kafka-connect-1.6.1.final:latest .
```

## Run the container

Pass in the environmental variables using `--env` parameter. Refer the next section for possible environmental variables.

```
docker run -d chengkuan/opay/kafka-connect-1.6.1.final:latest .
```

```
podman run -d chengkuan/opay/kafka-connect-1.6.1.final:latest .
```

## Run the container using docker compose

Change the settings according to your environment.

```
kafka-connect:
    image: chengkuan/opay/kafka-connect-1.6.1.final:latest
    ports:
     - 9080:9080
    links:
     - casa-postgres
     - kafka
     - core-postgres
    environment:
     - KAFKA_LOG4J_OPTS=-Dlog4j.configuration=file:/opt/kafka/config/connect-log4j.properties
     - KAFKA_CONNECT_BOOTSTRAP_SERVERS=kafka:9092
     - |
         KAFKA_CONNECT_CONFIGURATION=
         key.converter=org.apache.kafka.connect.json.JsonConverter
         value.converter=org.apache.kafka.connect.json.JsonConverter
         key.converter.schemas.enable=false
         value.converter.schemas.enable=false
         group.id=opay-connect
         offset.storage.topic=opay-offsets
         offset.storage.replication.factor=1
         config.storage.topic=opay-configs
         config.storage.replication.factor=1
         status.storage.topic=opay-status
         status.storage.replication.factor=1
         consumer.interceptor.classes=io.opentracing.contrib.kafka.TracingConsumerInterceptor
         producer.interceptor.classes=io.opentracing.contrib.kafka.TracingProducerInterceptor
         rest.advertised.port=9080
         rest.port=9080
```

## Create Connector

Prepares your respective connector config and post this config to the connector

```
curl -X POST -H 'Content-Type: application/json' -d {CONNECTOR_CONFIG_JSON or JSON_FILE} http://localhost:8083/connectors
```