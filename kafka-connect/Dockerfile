FROM quay.io/debezium/connect:2.3

ARG MONGODB_CONNECTOR_VERSION=1.9.1

RUN curl -sfSL -v -o ${KAFKA_CONNECT_PLUGINS_DIR}/mongo-kafka-connect-${MONGODB_CONNECTOR_VERSION}-all.jar https://repo1.maven.org/maven2/org/mongodb/kafka/mongo-kafka-connect/${MONGODB_CONNECTOR_VERSION}/mongo-kafka-connect-${MONGODB_CONNECTOR_VERSION}-all.jar

