#!/bin/bash

function print_usage {
    echo "Usage:"
    echo "$(basename $0) [OPTIONS]"
    echo "  [-k <kb-key>]: A unique key that will be used to name docker containers for this build"
    echo "  [-p <blazegraph-port>]: The port to use when starting blazegraph"
}

while getopts "k:p:h" OPTION; do
    case ${OPTION} in
        # A unique key that will be used to name docker containers for this build
        k) KB_KEY=$OPTARG
           ;;
        # port
        p) BLAZEGRAPH_PORT=$OPTARG
           ;;
        # HELP!
        h) print_usage; exit 0
           ;;
    esac
done

if [[ -z ${KB_KEY} || -z ${BLAZEGRAPH_PORT} ]]; then
    print_usage
    exit 1
fi

if ! [[ -e README.md ]]; then
    echo "Please run from the root of the project."
    exit 1
fi

# Create a Docker volume where blazegraph will store its data:
# This directory must be aligned with the directory specified in the RWStore.properties file

echo "Creating container for the blazegraph data..."
docker create -v /blazegraph-data --name blazegraph-data-${KB_KEY} alpine:latest

# Create a Docker volume where load requests can be placed
echo "Creating container for the blazegraph load requests..."
docker create -v /blazegraph-load-requests --name blazegraph-load-requests-${KB_KEY} alpine:latest

# Build the Docker image (this will import the AllegroGraph Docker image):
echo "Building the ccp/blazegraph image..."
docker build -t ccp/blazegraph:v2.1.4 blazegraph/

# Create a dedicated network so that other containers can talk to the agraph container
docker network create blazegraph-net-${KB_KEY}

# Start up Blazegraph
echo "Starting the blazegraph container..."
docker run -d -p 8889:8080 \
       -e BLAZEGRAPH_PORT=${BLAZEGRAPH_PORT} \
       --net blazegraph-net-${KB_KEY} \
       --volumes-from blazegraph-data-${KB_KEY} --volumes-from kabob_data-${KB_KEY} --volumes-from blazegraph-load-requests-${KB_KEY} \
       --name blazegraph-${KB_KEY} ccp/blazegraph:v2.1.4

# Log the port to the load-requests directory
echo "final adjustments to the blazegraph container..."
# pause is required to allow the blazegraph container to initialize prior to running echo_supervisord_conf
sleep 5
docker exec blazegraph-${KB_KEY} /bin/bash -c "/supervisord-config.sh"
docker exec blazegraph-${KB_KEY} /bin/bash -c "echo ${BLAZEGRAPH_PORT} > /blazegraph-load-requests/blazegraph.port"
docker exec blazegraph-${KB_KEY} /bin/bash -c "echo 'blazegraph-${KB_KEY}' > /blazegraph-load-requests/blazegraph.container.name"

