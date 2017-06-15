FROM tenforce/virtuoso:1.1.1-virtuoso7.2.4

RUN apt-get install -y supervisor inotify-tools

COPY supervisord.conf /etc/
COPY config/virtuoso.ini /
COPY config/virtuoso.ini /usr/local/virtuoso-opensource/var/lib/virtuoso/db/
COPY init-virtuoso.sh check-for-load.sh register-files-with-virtuoso-loader.sh run-virtuoso-loader.sh check-load-states.sh /usr/bin/


RUN chmod 600 /etc/supervisord.conf && \
    chmod 755 /virtuoso.sh && \
    # create the agraph.cfg file with the user-supplied license header
    chmod 755 /usr/bin/*.sh && \
    chmod 444 /usr/local/virtuoso-opensource/var/lib/virtuoso/db/virtuoso.ini
    #chmod 777 /usr/local/virtuoso-opensource/var/lib/virtuoso/db/virtuoso.ini && \
    #cp /virtuoso.ini /usr/local/virtuoso-opensource/var/lib/virtuoso/db/virtuoso.ini.2 && \
    #chmod 644 /usr/local/virtuoso-opensource/var/lib/virtuoso/db/virtuoso.ini
    # create log files that get used during load/query
    #touch /agload.log && \
    #chown agraph /agload.log && \
    #touch /agquery.log && \
    #chown agraph /agquery.log

# starting supervisord will start both virtuoso and the script
# that looks to see if there are files to load
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]