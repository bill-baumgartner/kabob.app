#!/bin/bash
#
# This script provides a way to re-download and process an individual ontology file

KB_KEY=$1
DATASOURCE_KEY=$2
ONT_URL=$3

DID=""
echo "Starting kabob-base container to process ${ONT_URL}..."
DID=${DID}" "`docker run -d --name "ccp_ont_dload_${DATASOURCE_KEY}" --volumes-from kabob_data-${KB_KEY} billbaumgartner/kabob-base:0.3 ./download-single-ontology.sh ${ONT_URL}`
docker wait $DID
docker rm $DID
