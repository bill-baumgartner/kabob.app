#!/bin/bash

#
# This script takes a single argument to allow
# different KaBOB instances to be run in the same Docker environment. The
# argument will be appended to the Virtuoso data volume name as well as
# the Virtuoso container name so that they can be uniquely identified.
#

function print_usage {
    echo "Usage:"
    echo "$(basename $0) [OPTIONS]"
    echo "  [-k <kb-key>]: A unique key that will be used to name docker containers for this build"
}

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

KB_KEY=$1

# Create a Docker volume where AllegroGraph will store its data: 
docker create -v /data --name virtuoso-data-$KB_KEY ubuntu:latest

# Create a Docker volume where load requests can be placed
docker create -v /virtuoso-load-requests --name virtuoso-load-requests-$KB_KEY ubuntu:latest

# Build the Docker image (this will import the AllegroGraph Docker image): 
docker build -t ccp/virtuoso --no-cache virtuoso/build/

# Create a dedicated network so that other containers can talk to the virtuoso container
docker network create virtuoso-net-$KB_KEY

# Start up Virtuoso image
docker run -d -p 8890:8890 -p 1111:1111 \
       --net virtuoso-net-$KB_KEY \
       -e DBA_PASSWORD=dba \
       -e SPARQL_UPDATE=true \
       -e DEFAULT_GRAPH=http://ccp.ucdenver.edu/default/ \
       --volumes-from virtuoso-data-$KB_KEY --volumes-from kabob_data-$KB_KEY --volumes-from virtuoso-load-requests-$KB_KEY \
       --name kabob-virtuoso-$KB_KEY ccp/virtuoso

# Log the Virtuoso port to the virtuoso-load-requests directory
docker exec agraph-$KB_KEY /bin/bash -c "echo 8890 > /virtuoso-load-requests/virtuoso.port"
