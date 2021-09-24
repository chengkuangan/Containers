FROM ubuntu:20.04

ARG MONGODB_VERSION="5.0.2"
ENV CONTAINER_VERSION="1.0.0"
ENV CONTAINER_NAME="Mongodb Container"

LABEL name="${CONTAINER_NAME}" \
      io.k8s.display-name="${CONTAINER_NAME}" \
      io.k8s.description="${CONTAINER_NAME}" \
      summary="${CONTAINER_NAME}" \
      io.openshift.tags="mongodb" \
      version="${MONGODB_VERSION}" \
      release="${CONTAINER_VERSION}" \
      maintainer="CK Gan <chengkuan@gmail.com>"

USER root

RUN apt-get update && apt-get install -y wget libcurl4 openssl liblzma5

ENV MONGODB_HOME /opt/mongodb
ENV MONGODB_BIN ${MONGODB_HOME}/bin
ENV PATH $MONGODB_BIN:$PATH
ENV MONGODATA_PATH /var/lib/mongodb

RUN cd /opt && wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu2004-${MONGODB_VERSION}.tgz && \
tar -xvzf mongodb-linux-x86_64-ubuntu2004-${MONGODB_VERSION}.tgz && \
rm mongodb-linux-x86_64-ubuntu2004-${MONGODB_VERSION}.tgz && \
mv mongodb-linux-x86_64-ubuntu2004-${MONGODB_VERSION} ${MONGODB_HOME}

COPY ./startmongod.sh ${MONGODB_BIN}/startmongod.sh

VOLUME ${MONGODATA_PATH}

EXPOSE 27017

CMD ${MONGODB_BIN}/startmongod.sh