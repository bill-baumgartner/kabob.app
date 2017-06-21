#!/bin/bash

#
# Build KaBOB
#

while getopts "k:h" OPTION; do
    case ${OPTION} in
        # A unique key that will be used to name docker containers for this build
        k) KB_KEY=$OPTARG
           ;;
        # HELP!
        h) print_usage; exit 0
           ;;
    esac
done

if [[ -z ${KB_KEY} ]]; then
    print_usage
    exit 1
fi

if ! [[ -e README.md ]]; then
    echo "Please run from the root of the project."
    exit 1
fi

# Build KaBOB using the RDF generated from downloaded data sources:
docker run --rm --net virtuoso-net-${KB_KEY} --volumes-from kabob_data-${KB_KEY} --volumes-from virtuoso-load-requests-${KB_KEY} billbaumgartner/kabob-base:0.3 /kabob.git/scripts/docker/build-from-scratch-virtuoso.sh
