#!/bin/bash

#
# Build KaBOB
#

if ! [[ -e README.md ]]; then
    echo "Please run from the root of the project."
    exit 1
fi

KB_KEY=$1
KB_NAME=$2

# Build KaBOB using the RDF generated from downloaded data sources:
docker run --rm --net virtuoso-net-$KB_KEY --volumes-from kabob_data-$KB_KEY --volumes-from virtuoso-load-requests-$KB_KEY billbaumgartner/kabob-base:0.3 /kabob.git/scripts/docker/build-from-scratch-virtuoso.sh
