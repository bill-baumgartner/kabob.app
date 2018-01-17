FROM lyrasis/blazegraph:2.1.4

USER root
RUN apk --no-cache add \
    unzip \
    supervisor \
    inotify-tools \
    less \
    vim \
    maven \
    bash

# the following supplants the existing RWStore.properties file
COPY scripts/RWStore.properties /
COPY scripts/log4j.properties /
COPY scripts/supervisord-config.sh /
COPY scripts/supervisord.conf /etc/
COPY scripts/init-blazegraph.sh scripts/check-for-load.sh /usr/bin/

RUN chmod 600 /etc/supervisord.conf && \
    chmod 755 /usr/bin/*.sh && \
    chmod 755 /supervisord-config.sh && \
    mkdir /var/log/supervisor && \
    mkdir /blazegraph-data && \
    chown jetty:jetty /blazegraph-data && \
    mkdir /blazegraph-load-requests && \
    chown jetty:jetty /blazegraph-load-requests

CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]