FROM codercom/code-server:4.8.3-ubuntu

USER root

ENV OPT=/opt
ENV MAVEN_HOME=/$OPT/apache-maven-3.8.6
#ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64
ENV JAVA_HOME=/$OPT/jdk-19.0.1
ENV DEBIAN_FRONTEND noninteractive

#RUN apt-get -y update && \
#    apt-get install -y --no-install-recommends default-jdk && \
# cd /opt && \
#    curl -sfSL https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz | tar xz && \
#    ln -s $MAVEN_HOME/bin/mvn /usr/bin/mvn && \
#    apt-get autoremove && \
#    apt-get clean 

COPY --chown=root:root ./download-packages.sh /tmp

RUN chmod +x /tmp/download-packages.sh && \
    /tmp/download-packages.sh
    
USER coder