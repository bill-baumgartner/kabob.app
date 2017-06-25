#!/bin/bash
#
# This script provides a way to generate RDF for a single data source. It can be used
# if an error was detected and a data source needs to be re-processed.
#
# The first input parameter indicates the KB_KEY, allowing for
# multiple KaBOB builds in the same Docker environment.
#
# The second input parameter should be the data source key that needs to be re-processed
#
#
# This script inspired by:
# http://kimh.github.io/blog/en/docker/using-docker-to-run-cucumber-tests-in-parallel/
#

KB_KEY=$1
DATASOURCE_KEY=$2
TAX="-t 9606"
MAVEN="/usr/bin/mvn"

DID=""
echo "Starting kabob-base container to process: $DATASOURCE_KEY"
DID=${DID}" "`docker run -d --name "rdf_gen_${DATASOURCE_KEY}" --volumes-from kabob_data-$KB_KEY billbaumgartner/kabob-base:0.3 ./ice-rdf-gen.sh "${TAX}" "${DATASOURCE_KEY}" "${MAVEN}" "${DATASOURCE_KEY}"`
docker wait $DID
docker rm $DID
