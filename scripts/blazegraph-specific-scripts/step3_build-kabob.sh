#!/bin/bash

#
# Build KaBOB
#

function print_usage {
    echo "Usage:"
    echo "$(basename $0) [OPTIONS]"
    echo "  [-k <kb-key>]: A unique key that will be used to name docker containers for this build"
    echo "  [-c <command-to-run>]: The shell command to run, e.g. boot..."
    echo "  [-v <kabob docker image version>]: The version of the kabob docker image to use."

}

while getopts "k:c:v:h" OPTION; do
    case ${OPTION} in
        # A unique key that will be used to name docker containers for this build
        k) KB_KEY=$OPTARG
           ;;
        # The shell command to run
        c) SHELL_COMMAND=$OPTARG
           ;;
        # kabob docker image version
        v) VERSION=$OPTARG
           ;;
        # HELP!
        h) print_usage; exit 0
           ;;
    esac
done

if [[ -z ${KB_KEY} || -z ${SHELL_COMMAND} || -z ${VERSION} ]]; then
    print_usage
    exit 1
fi

if ! [[ -e README.md ]]; then
    echo "Please run from the root of the project."
    exit 1
fi

docker run --rm --net blazegraph-net-${KB_KEY} --volumes-from kabob_data-${KB_KEY} --volumes-from blazegraph-load-requests-${KB_KEY} billbaumgartner/kabob-base:${VERSION} "${SHELL_COMMAND}"
