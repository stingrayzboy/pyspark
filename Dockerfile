
FROM python:3.7-alpine
RUN apk update && apk upgrade
RUN apk add build-base
RUN apk add --no-cache bash\
                       pkgconfig \
                       git \
                       gcc \
                       openldap \
                       libcurl \
                       python2-dev \
                       gpgme-dev \
                       libc-dev \
    && rm -rf /var/cache/apk
RUN pip install jupyter

RUN apk add --no-cache openjdk8

ENV SCALA_VERSION=2.12.8 \
    SCALA_HOME=/usr/share/scala

# NOTE: bash is used by scala/scalac scripts, and it cannot be easily replaced with ash.

RUN apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    apk add --no-cache bash && \
    cd "/tmp" && \
    wget "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
    tar xzf "scala-${SCALA_VERSION}.tgz" && \
    mkdir "${SCALA_HOME}" && \
    rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat && \
    mv "/tmp/scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
    ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
    apk del .build-dependencies && \
    rm -rf "/tmp/"*

RUN pip install py4j

RUN wget "http://apachemirror.wuchna.com/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz"

RUN tar -xzvf spark-2.4.4-bin-hadoop2.7.tgz

RUN rm -f spark-2.4.4-bin-hadoop2.7.tgz

RUN mv spark-2.4.4-bin-hadoop2.7/ spark/

RUN export SPARK_HOME='spark-2.4.4-bin-hadoop2.7'

RUN export PATH=$SPARK_HOME:$PATH

RUN export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH

RUN export PYSPARK_DRIVER_PYTHON="jupyter"

RUN export PYSPARK_DRIVER_PYTHON_OPTS="notebook"

RUN export PYSPARK_PYTHON=python3

RUN pip install findspark 
