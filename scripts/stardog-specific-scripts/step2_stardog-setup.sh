#!/bin/bash

#
# Set up resources, build the custom AllegroGraph image, and start up
# AllegroGraph.  This script takes a single argument to allow
# different KaBOB instances to be run in the same Docker environment. The
# argument will be appended to the agraph data volume name as well as
# the agraph container name so that they can be uniquely identified.
#


function print_usage {
    echo "Usage:"
    echo "$(basename $0) [OPTIONS]"
    echo "  [-k <kb-key>]: A unique key that will be used to name docker containers for this build"
    echo "  [-p <stardog-port>]: The port to use when starting stardog"
}

while getopts "k:p:h" OPTION; do
    case ${OPTION} in
        # A unique key that will be used to name docker containers for this build
        k) KB_KEY=$OPTARG
           ;;
        # StarDog port
        p) STARDOG_PORT=$OPTARG
           ;;
        # HELP!
        h) print_usage; exit 0
           ;;
    esac
done

if [[ -z ${KB_KEY} || -z ${STARDOG_PORT} ]]; then
    print_usage
    exit 1
fi

if ! [[ -e README.md ]]; then
    echo "Please run from the root of the project."
    exit 1
fi

# Create a Docker volume where Stardog will store its data:
docker create -v /stardog-data --name stardog-data-${KB_KEY} ubuntu:latest

# Create a Docker volume where load requests can be placed
docker create -v /kabob-load-requests --name stardog-load-requests-${KB_KEY} ubuntu:latest

# Build the Docker image (this will import the AllegroGraph Docker image): 
docker build -t ccp/stardog:v5.0 stardog/

# Create a dedicated network so that other containers can talk to the agraph container
docker network create stardog-net-${KB_KEY}

# Start up Stardog
docker run -d -p ${STARDOG_PORT}:${STARDOG_PORT} \
       -e STARDOG_PORT=${STARDOG_PORT} \
       --net stardog-net-${KB_KEY} \
       --volumes-from stardog-data-${KB_KEY} --volumes-from kabob_data-${KB_KEY} --volumes-from stardog-load-requests-${KB_KEY} \
       --name stardog-${KB_KEY} ccp/stardog:v5.0

# Log the AllegroGraph port to the kabob-load-requests directory
docker exec stardog-${KB_KEY} /bin/bash -c "echo ${STARDOG_PORT} > /kabob-load-requests/stardog.port"
docker exec stardog-${KB_KEY} /bin/bash -c "echo 'stardog-${KB_KEY}' > /kabob-load-requests/stardog.container.name"

