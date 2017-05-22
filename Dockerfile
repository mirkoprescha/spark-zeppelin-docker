FROM ubuntu:16.10
MAINTAINER mirkoprescha

ARG ZEPPELIN_VERSION="0.7.1"
ARG SPARK_VERSION="2.1.0"
ARG HADOOP_VERSION="2.7"

LABEL zeppelin.version=${ZEPPELIN_VERSION}
LABEL spark.version=${SPARK_VERSION}
LABEL hadoop.version=${HADOOP_VERSION}


RUN apt-get -y update
RUN apt-get -y install curl less
RUN apt-get -y install vim
#RUN apt-get -y install software-properties-common

# Install Java
RUN apt-get update && apt-get install -y default-jdk



##########################################
# SPARK
##########################################
RUN mkdir /usr/local/spark
ARG SPARK_ARCHIVE=http://d3kbcqa49mib13.cloudfront.net/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
ENV SPARK_HOME /usr/local/spark

ENV PATH $PATH:${SPARK_HOME}/bin
RUN curl -s ${SPARK_ARCHIVE} | tar -xz -C  /usr/local/spark --strip-components=1

# for spark history server
COPY spark-defaults.conf ${SPARK_HOME}/conf/
RUN mkdir /tmp/spark-events


##########################################
# Zeppelin
##########################################
RUN mkdir /usr/zeppelin

RUN curl -s http://apache.mirror.digionline.de/zeppelin/zeppelin-${ZEPPELIN_VERSION}/zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz | tar -xz -C /usr/zeppelin

RUN echo '{ "allow_root": true }' > /root/.bowerrc

ENV ZEPPELIN_PORT 8080
ENV ZEPPELIN_HOME /usr/zeppelin/zeppelin-${ZEPPELIN_VERSION}-bin-all
ENV ZEPPELIN_CONF_DIR $ZEPPELIN_HOME/conf
ENV ZEPPELIN_NOTEBOOK_DIR $ZEPPELIN_HOME/notebook

RUN mkdir -p $ZEPPELIN_HOME \
  && mkdir -p $ZEPPELIN_HOME/logs \
  && mkdir -p $ZEPPELIN_HOME/run



# my WorkDir
RUN mkdir /work
WORKDIR /work


ENTRYPOINT  /usr/local/spark/sbin/start-history-server.sh; $ZEPPELIN_HOME/bin/zeppelin-daemon.sh start  && bash

