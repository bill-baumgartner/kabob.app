FROM franzinc/agraph:v6.1.1

# install maven
RUN yum install -y wget && \
    wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo && \
    sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo && \
    yum install -y apache-maven && \
    mvn --version

# install Zulu OpenJDK v8
RUN rpm --import http://repos.azulsystems.com/RPM-GPG-KEY-azulsystems && \
    curl -o /etc/yum.repos.d/zulu.repo http://repos.azulsystems.com/rhel/zulu.repo && \
    yum install -y zulu-8 && \
    mvn --version

COPY config/user-env.sh config/update-agraph-cfg.sh /config/ 

# create the agraph.cfg file with the user-supplied license header
RUN chmod 755 /config/update-agraph-cfg.sh && \
    /config/update-agraph-cfg.sh && \
    touch /agload.log && \
    chown agraph /agload.log

# start AG
CMD /app/agraph/bin/agraph-control --config /config/agraph.cfg start \
    && tail -f /data/log/agraph.log
    
