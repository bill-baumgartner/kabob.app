# Zulu is a certified build of OpenJDK that is redistributable (unlike
# Oracle Java): https://www.azul.com/products/zulu
# This Zulu distribution is based on ubuntu:latest
FROM azul/zulu-openjdk:8u92

RUN apt-get update && apt-get install -y \
    unzip \
    supervisor \
    inotify-tools \
    less \
    vim

ENV STARDOG_VERSION=5.3.3 \
    STARDOG_HOME=/stardog-data


COPY scripts/supervisord.conf /etc/
COPY scripts/init-stardog.sh scripts/check-for-load.sh /usr/bin/

RUN chmod 600 /etc/supervisord.conf && \
    chmod 755 /usr/bin/*.sh

COPY stardog_download/stardog-${STARDOG_VERSION}.zip /

RUN unzip /stardog-${STARDOG_VERSION}.zip

COPY stardog_download/stardog-license-key.bin /stardog-${STARDOG_VERSION}/
COPY scripts/stardog.properties /stardog-${STARDOG_VERSION}/

#EXPOSE $STARDOG_PORT

# CMD borrowed from: https://hub.docker.com/r/nice/ld-docker-stardog/~/dockerfile/
#CMD rm -f ${STARDOG_HOME}/system.lock || true && \
#    cp /stardog-${STARDOG_VERSION}/stardog-license-key.bin ${STARDOG_HOME} && \
#    /stardog-${STARDOG_VERSION}/bin/stardog-admin server start && \
#    sleep 1 && \
#    (tail -f ${STARDOG_HOME}/stardog.log &) && \
#    while (pidof java > /dev/null); do sleep 1; done

CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]