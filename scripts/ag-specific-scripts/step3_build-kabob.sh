#!/bin/bash

#
# Build KaBOB
#

function print_usage {
    echo "Usage:"
    echo "$(basename $0) [OPTIONS]"
    echo "  [-k <kb-key>]: A unique key that will be used to name docker containers for this build"
    echo "  [-n <kb-name>]: The name of the AllegroGraph repository that will be populated as KaBOB, e.g kabob-prod"
}

while getopts "k:n:h" OPTION; do
    case ${OPTION} in
        # A unique key that will be used to name docker containers for this build
        k) KB_KEY=$OPTARG
           ;;
        # A unique name of the AllegroGraph repository that will be populated as KaBOB, e.g kabob-prod
        n) KB_NAME=$OPTARG
           ;;
        # HELP!
        h) print_usage; exit 0
           ;;
    esac
done

if [[ -z ${KB_KEY} || -z ${KB_NAME} ]]; then
    print_usage
    exit 1
fi

if ! [[ -e README.md ]]; then
    echo "Please run from the root of the project."
    exit 1
fi

# Build KaBOB using the RDF generated from downloaded data sources:
docker run --rm --net agraph-net-${KB_KEY} --volumes-from kabob_data-${KB_KEY} --volumes-from ag-load-requests-${KB_KEY} billbaumgartner/kabob-base:0.3 /kabob.git/scripts/docker/allegrograph-specific/build-from-scratch-ag.sh -n ${KB_NAME}
