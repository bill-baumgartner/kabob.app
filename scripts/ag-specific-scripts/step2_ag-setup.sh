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

# make sure the $PLATFORM_ALLEGROGRAPH_PORT environment variable is set
source allegrograph/build/config/user-env.sh

# Create and commit an image based on franzinc/agraph:v6.4.1 that has
# Transparent Hugepages (THP) disabled. As noted in the AllegroGraph
# documentation, THP can result in poor AllegroGraph performance:
# http://franz.com/agraph/support/documentation/current/performance-tuning.html#header3-18
#
# --cap-add=SYS_ADMIN is required in order to make /sys writeable
# after THP has been disabled, /sys is made read-only once again
docker run -d -m 1g -p 10000-10035:10000-10035 --shm-size 1g --cap-add=SYS_ADMIN --name agraph-${KB_KEY} franzinc/agraph:v6.4.5
docker exec agraph-${KB_KEY}  /bin/bash -c "yum install -y mount;
                                  mount -o remount,rw /sys ;
                                  echo never > /sys/kernel/mm/transparent_hugepage/enabled ;
                                  echo never > /sys/kernel/mm/transparent_hugepage/defrag ;
                                  mount -o remount,ro /sys;
                                  /app/agraph/bin/agraph-control --config /data/etc/agraph.cfg stop"
# commit a new image with THP disabled
docker commit agraph-${KB_KEY} franzinc/agraph:v6.4.5.THP_disabled
docker stop agraph-${KB_KEY}
docker rm agraph-${KB_KEY}

# Create a Docker volume where AllegroGraph will store its data: 
docker create --name agraph-data-${KB_KEY} franzinc/agraph-data

# Create a Docker volume where load requests can be placed
docker create -v /kabob-load-requests --name ag-load-requests-${KB_KEY} ubuntu:latest

# Build the Docker image (this will import the AllegroGraph Docker image): 
docker build -t ccp/agraph:v6.4.5 allegrograph/build/

# Create a dedicated network so that other containers can talk to the agraph container
docker network create agraph-net-${KB_KEY}

# Start up AllegroGraph
docker run -d -p 10000-${PLATFORM_ALLEGROGRAPH_PORT}:10000-${PLATFORM_ALLEGROGRAPH_PORT} \
       --net agraph-net-${KB_KEY} \
       --shm-size 1g \
       -m 1g \
       --volumes-from agraph-data-${KB_KEY} --volumes-from kabob_data-${KB_KEY} --volumes-from ag-load-requests-${KB_KEY} \
       --name agraph-${KB_KEY} ccp/agraph:v6.4.5

# Log the AllegroGraph port to the kabob-load-requests directory
docker exec agraph-${KB_KEY} /bin/bash -c "echo ${PLATFORM_ALLEGROGRAPH_PORT} > /kabob-load-requests/agraph.port"
docker exec agraph-${KB_KEY} /bin/bash -c "echo 'agraph-${KB_KEY}' > /kabob-load-requests/agraph.container.name"

