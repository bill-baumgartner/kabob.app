# Zulu is a certified build of OpenJDK that is redistributable (unlike
# Oracle Java): https://www.azul.com/products/zulu
# This Zulu distribution is based on ubuntu:latest
FROM azul/zulu-openjdk:8u92

RUN apt-get update && apt-get install -y \
    unzip

ENV STARDOG_VERSION=5.0 \
    STARDOG_HOME=/stardog-data

COPY stardog_download/stardog-${STARDOG_VERSION}.zip /

RUN unzip /stardog-${STARDOG_VERSION}.zip

COPY stardog_download/stardog-license-key.bin /stardog-${STARDOG_VERSION}/

EXPOSE 5820

# CMD borrowed from: https://hub.docker.com/r/nice/ld-docker-stardog/~/dockerfile/
CMD rm -f ${STARDOG_HOME}/system.lock || true && \
    cp /stardog-${STARDOG_VERSION}/stardog-license-key.bin ${STARDOG_HOME} && \
    ./bin/stardog-admin server start && \
    sleep 1 && \
    (tail -f ${STARDOG_HOME}/stardog.log &) && \
    while (pidof java > /dev/null); do sleep 1; done