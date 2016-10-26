FROM franzinc/agraph:v6.1.1.THP_disabled

# install supervisor & inotify-tools
RUN yum install -y epel-release && \
    yum clean all && \
    yum -y update && \
    yum -y install supervisor inotify-tools && \
    yum clean all

COPY supervisord.conf /etc/
COPY config/user-env.sh update-agraph-cfg.sh /config/
COPY init-agraph.sh check-for-load.sh /usr/bin/

RUN chmod 600 /etc/supervisord.conf && \
    # create the agraph.cfg file with the user-supplied license header
    chmod 755 /config/update-agraph-cfg.sh /usr/bin/*.sh  && \
    /config/update-agraph-cfg.sh && \
    # create log files that get used during load/query
    touch /agload.log && \
    chown agraph /agload.log && \
    touch /agquery.log && \
    chown agraph /agquery.log

# starting supervisord will start both allegrograph and the script
# that looks to see if there are files to load
CMD ["/usr/bin/supervisord"]

    
