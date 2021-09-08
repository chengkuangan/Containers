# Kafka Container

This provides a Kafka and Zookeeper all in one container built for demo and development purpose.

It expose 2 ports `9092` and `9093`. `9092` hardcoded to `kafka` service name and `9093` exposed to localhost. It is usefull when you need to connect to the Kafka broker while doing development. 
You can run your application in dev mode and connect to Kafka broker at `localhost:9093`.
Applications running using `docker compose` can connect to `kafka:9092`

## Build the container image

Change directory to the project root directory and run the container build command:

```
docker build -t chengkuan/opay/kafka-2.13-2.8.0:latest .
```

```
podman build -t chengkuan/opay/kafka-2.13-2.8.0:latest .
```

## To run

- To run with podman or docker:

```
docker run chengkuan/opay/kafka-2.13-2.8.0:latest -p 9092:9092 -p 9093:9093 
```
```
podman run chengkuan/opay/kafka-2.13-2.8.0:latest -p 9092:9092 -p 9093:9093 
```
- To run it in docker compose:
```
services:
  kafka:    // the port 9092 hardcoded to kafka service name
    image: chengkuan/opay/kafka-2.13-2.8.0:latest
    ports:
     - 9092:9092
     - 9093:9093
    healthcheck:
      test:
        ["CMD", "kafka-topics.sh", "--bootstrap-server", "kafka:9092", "--list"]
      interval: 30s
      timeout: 10s
      retries: 10 
```