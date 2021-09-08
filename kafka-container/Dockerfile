FROM ubuntu:20.04

ENV KAFKA_VERSION="2.13-2.8.0"
ENV CONTAINER_VERSION="1.0.0"
ENV CONTAINER_NAME="Kafka Container"
ENV KAFKA_PATH="/opt/kafka_${KAFKA_VERSION}"
LABEL name="${CONTAINER_NAME}" \
      io.k8s.display-name="${CONTAINER_NAME}" \
      io.k8s.description="${CONTAINER_NAME}" \
      summary="${CONTAINER_NAME}" \
      io.openshift.tags="kafka" \
      version="${MONGODB_VERSION}" \
      release="${CONTAINER_VERSION}" \
      maintainer="CK Gan <chengkuan@gmail.com>"

ENV PATH=${PATH}:${KAFKA_PATH}/bin

USER root:root

RUN apt-get update && apt-get install -y curl default-jdk

RUN cd /opt && curl -sfSL https://archive.apache.org/dist/kafka/2.8.0/kafka_${KAFKA_VERSION}.tgz | tar xz

COPY startKafka.sh ${KAFKA_PATH}/bin/startKafka.sh

EXPOSE 2181 2888 3888 9092

CMD ${KAFKA_PATH}/bin/startKafka.sh