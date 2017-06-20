#!/bin/bash

#
# Download datasources and generate RDF. This script takes two input arguments.
#
# The first input parameter is a key that will be used to distinguish
# this build from other KB builds in the same Docker environment, e.g
# production vs. development.
#
# Note that this script is capable of using a variable number (1-5) of
# docker containers to download and process the data sources in parallel. The
# second input parameter indicates the number of docker containers to
# use (and should be no more than the number of available cores on
# your machine).
#
#

if ! [[ -e README.md ]]; then
    echo "Please run from the root of the project."
    exit 1
fi

KB_KEY=$1
CONTAINER_COUNT=$2

# Create a Docker volume where the downloaded data files and generated RDF will be stored: 
docker create -v /kabob_data --name kabob_data-$KB_KEY ubuntu:latest

#  Initial setup (downloads ontologies used by KaBOB): 
docker run --rm --volumes-from kabob_data-$KB_KEY billbaumgartner/kabob-base:0.3 ./setup.sh


# Create data source RDF (downloads and processes publicly available databases).
chmod 755 scripts/human-ice-rdf-gen.sh
scripts/human-ice-rdf-gen.sh $KB_KEY $CONTAINER_COUNT
