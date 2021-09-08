#!/bin/bash

${KAFKA_PATH}/bin/zookeeper-server-start.sh -daemon ${KAFKA_PATH}/config/zookeeper.properties

#OVERRIDE=""

#if [[ ! -z "${KAFKA_ADVERTISED_HOSTNAME}" ]]; then
#  OVERRIDE="--override advertised.listeners=PLAINTEXT://${KAFKA_ADVERTISED_HOSTNAME}:9092"
#fi

${KAFKA_PATH}/bin/kafka-server-start.sh ${KAFKA_PATH}/config/server.properties --override listener.security.protocol.map=PLAINTEXT:PLAINTEXT,EXTERNAL:PLAINTEXT --override listeners=PLAINTEXT://0.0.0.0:9092,EXTERNAL://0.0.0.0:9093 --override advertised.listeners=PLAINTEXT://kafka:9092,EXTERNAL://localhost:9093
