#!/bin/bash

ARC="$(dpkg --print-architecture)"

if [ "$ARC" = "amd64" ]; then
    cd /usr/bin/ && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl
    cd /opt/ && curl -sfSL https://download.java.net/java/GA/jdk19.0.1/afdd2e245b014143b62ccb916125e3ce/10/GPL/openjdk-19.0.1_linux-x64_bin.tar.gz | tar xz && ln -s $JAVA_HOME/bin/java /usr/bin/java && ln -s $JAVA_HOME/bin/javac /usr/bin/javac
else
    cd /usr/bin/ && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" && chmod +x kubectl
    cd /opt/ && curl -sfSL https://download.java.net/java/GA/jdk19.0.1/afdd2e245b014143b62ccb916125e3ce/10/GPL/openjdk-19.0.1_linux-aarch64_bin.tar.gz | tar xz && ln -s $JAVA_HOME/bin/java /usr/bin/java && ln -s $JAVA_HOME/bin/javac /usr/bin/javac
fi

cd $OPT/ && curl -sfSL https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz | tar xz && ln -s $MAVEN_HOME/bin/mvn /usr/bin/mvn
