FROM registry.redhat.io/amq7/amq-streams-kafka-28-rhel8:1.8.0-4
#FROM registry.redhat.io/amq7/amq-streams-kafka-26-rhel7:1.6.0
#FROM strimzi/kafka:0.18.0-kafka-2.5.0

ENV DEBEZIUM_VERSION="1.6.1.Final"
ENV CONTAINER_VERSION="1.0.0"
ENV KAFKA_VERSION="2.8"
ENV POSTGRES_CONNECTOR_VERSION="1.6.1.Final"
ENV DEBEZIUM_SCRIPTING_VERSION="1.3.1.Final"
ENV CONTAINER_NAME="OPay Kafka Connect"
ENV KAFKA_CONNECT_PLUGIN_PATH="/opt/kafka/plugins"
ENV MONGODB_CONNECTOR_VERSION="1.6.1"

LABEL name="${CONTAINER_NAME}" \
      io.k8s.display-name="${CONTAINER_NAME}" \
      io.k8s.description="${CONTAINER_NAME}" \
      summary="${CONTAINER_NAME}" \
      io.openshift.tags="Kafka,Connect,Debezium,Postgres,MongoDB" \
      version="${CONTAINER_VERSION}" \
      release="${CONTAINER_VERSION}" \
      maintainer="CK Gan <chengkuan@gmail.com>" \
      debezium.version="${DEBEZIUM_VERSION}" \
      kafka.version="${KAFKA_VERSION}}" \
      connector.postgres.version="${POSTGRES_CONNECTOR_VERSION}" \
      connector.mongodb.version="${MONGODB_CONNECTOR_VERSION}"

USER root:root
RUN mkdir -p ${KAFKA_CONNECT_PLUGIN_PATH} && \
    cd ${KAFKA_CONNECT_PLUGIN_PATH} && \
    curl -sfSL https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/${POSTGRES_CONNECTOR_VERSION}/debezium-connector-postgres-${POSTGRES_CONNECTOR_VERSION}-plugin.tar.gz | tar xz && \
    curl -sfS https://repo1.maven.org/maven2/io/debezium/debezium-scripting/1.3.1.Final/debezium-scripting-${DEBEZIUM_SCRIPTING_VERSION}.jar -o debezium-scripting-${DEBEZIUM_SCRIPTING_VERSION}.jar && \
    curl -sfS https://repo1.maven.org/maven2/org/mongodb/kafka/mongo-kafka-connect/${MONGODB_CONNECTOR_VERSION}/mongo-kafka-connect-${MONGODB_CONNECTOR_VERSION}-all.jar -o mongo-kafka-connect-${MONGODB_CONNECTOR_VERSION}-all.jar
USER 1001