FROM codercom/code-server:4.8.3-ubuntu

USER root

ENV MAVEN_HOME=/opt/apache-maven-3.8.6
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y install -y curl default-jdk && \
    cd /opt && \
    curl -sfSL https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz | tar xz && \
    ln -s $MAVEN_HOME/bin/mvn /usr/bin/mvn

COPY --chown=root:root ./download-kubectl.sh /tmp
RUN chmod +x /tmp/download-kubectl.sh && \
    /tmp/download-kubectl.sh
    
USER coder