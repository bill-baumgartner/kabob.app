#!/bin/bash
#
# This script provides a way to re-download and process the ccp-extension ontology

KB_KEY=$1
DATASOURCE_KEY=$2

DID=""
echo "Starting kabob-base container to process ccp-extension ontology..."
DID=${DID}" "`docker run -d --name "ccp_ont_dload_${DATASOURCE_KEY}" --volumes-from kabob_data-${KB_KEY} billbaumgartner/kabob-base:0.3 ./download-single-ontology.sh https://raw.githubusercontent.com/UCDenver-ccp/ccp-extension-ontology/master/src/ontology/ccp-extensions.owl`
docker wait $DID
docker rm $DID
