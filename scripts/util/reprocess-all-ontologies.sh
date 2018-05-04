#!/bin/bash
#
# This script provides a way to re-download and process the ccp-extension ontology

KB_KEY=$1

DID=""
echo "Starting kabob-base container to process all ontologies..."
DID=${DID}" "`docker run -d --name "ontology_processing" --volumes-from kabob_data-${KB_KEY} billbaumgartner/kabob-base:0.3 ./download-ontologies.sh`
docker wait $DID
docker rm $DID
