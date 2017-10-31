#FROM jupyter/scipy-notebook
FROM beakerx/beakerx

USER root

RUN pip install sparqlkernel && \
    jupyter sparqlkernel install

RUN apt-get update && apt-get install -y \
    maven \
    wget \
    vim

# install Clojure/Leiningen
RUN wget -q -O /usr/local/bin/lein https://raw.githubusercontent.com/technomancy/leiningen/2.7.1/bin/lein && \
    chmod +x /usr/local/bin/lein

# install kr
RUN git clone --branch leiningen-sesame4 https://github.com/bill-baumgartner/kr.git ./kr.git && \
    cd ./kr.git && \
    lein install && \
    lein uberjar && \
    cd ..

# install the kabob project
RUN git clone https://github.com/bill-baumgartner/kabob.git ./kabob.git && \
    cd ./kabob.git && \
    ./scripts/download/download-virtuoso-dependencies.sh mvn && \
    lein install && \
    lein uberjar && \
    cd ..

# copy the kabob uberjar to the beaker lib directory and update the beakerx/clojure classpath to include it
# delete the included httpclient and httpcore jars as newer versions are included in the kabob uberjar
RUN mv /home/beakerx/kabob.git/target/uberjar/kabob-2.0.0-SNAPSHOT-standalone.jar /home/beakerx/beakerx/beakerx/static/kernel/clojure/lib && \
    rm /home/beakerx/beakerx/beakerx/static/kernel/clojure/lib/http*.jar && \
    sed -i 's/plexus-utils-3.0.jar/plexus-utils-3.0.jar:$APP_HOME\/lib\/kabob-2.0.0-SNAPSHOT-standalone.jar/' /home/beakerx/beakerx/beakerx/static/kernel/clojure/bin/clojure && \
    mkdir /home/beakerx/kabob-notebooks && \
    mkdir /home/beakerx/test-triple-files && \
    chown beakerx:beakerx /home/beakerx/beakerx/beakerx/static/kernel/clojure/lib/kabob-2.0.0-SNAPSHOT-standalone.jar





