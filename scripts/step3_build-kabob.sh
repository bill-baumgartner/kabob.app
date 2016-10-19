#!/bin/bash

#
# Build KaBOB
#

if ! [[ -e README.md ]]; then
    echo "Please run from the root of the project."
    exit 1
fi

# Build KaBOB using the RDF generated from downloaded data sources:
docker exec agraph bash -c "/kabob.git/scripts/docker/build-from-scratch.sh"
