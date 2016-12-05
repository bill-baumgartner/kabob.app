#!/bin/bash

#
# Download datasources and generate RDF. Note that this script spins
# up 1-5 docker containers to download and process the data
# sources. The single input parameter indicates the number of
# docker containers to use (and should be no more than the number
# of available cores on your machine).
#

if ! [[ -e README.md ]]; then
    echo "Please run from the root of the project."
    exit 1
fi

# Create a Docker volume where the downloaded data files and generated RDF will be stored: 
docker create -v /kabob_data --name kabob_data ubuntu:latest

#  Initial setup (downloads ontologies used by KaBOB): 
docker run --rm --volumes-from kabob_data billbaumgartner/kabob-base:0.2 ./setup.sh


# Create data source RDF (downloads and processes publicly available databases).
chmod 755 scripts/human-ice-rdf-gen.sh
scripts/human-ice-rdf-gen.sh $1
