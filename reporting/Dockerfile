#FROM jupyter/scipy-notebook
FROM beakerx/beakerx

USER root

#RUN conda install -c conda-forge ipywidgets beakerx

RUN pip install sparqlkernel && \
    jupyter sparqlkernel install

RUN apt-get update && apt-get install -y \
    maven \
    wget

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

#RUN jupyter nbextension enable beakerx --py --sys-prefix

#RUN chown -R jovyan:users /home/jovyan/.local
#USER jovyan