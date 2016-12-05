#!/bin/bash

#
# Build KaBOB
#

if ! [[ -e README.md ]]; then
    echo "Please run from the root of the project."
    exit 1
fi

# Build KaBOB using the RDF generated from downloaded data sources:
docker run --rm --net agraph-net --volumes-from kabob_data --volumes-from ag-load-requests billbaumgartner/kabob-base:0.2 /kabob.git/scripts/docker/build-from-scratch.sh $1
