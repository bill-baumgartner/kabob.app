#!/bin/bash

#
# Set up resources, build the custom AllegroGraph image, and start up
# AllegroGraph.  This script takes a single argument to allow
# different KaBOB instances to be run in the same Docker environment. The
# argument will be appended to the agraph data volume name as well as
# the agraph container name so that they can be uniquely identified.
#

if ! [[ -e README.md ]]; then
    echo "Please run from the root of the project."
    exit 1
fi

KB_KEY=$1

# make sure the $PLATFORM_ALLEGROGRAPH_PORT environment variable is set
source allegrograph/build/config/user-env.sh

# Create and commit an image based on franzinc/agraph:v6.1.1 that has
# Transparent Hugepages (THP) disabled. As noted in the AllegroGraph
# documentation, THP can result in poor AllegroGraph performance:
# http://franz.com/agraph/support/documentation/current/performance-tuning.html#header3-18
#
# --cap-add=SYS_ADMIN is required in order to make /sys writeable
# after THP has been disabled, /sys is made read-only once again
docker run -d --cap-add=SYS_ADMIN --name agraph franzinc/agraph:v6.1.1
docker exec agraph  /bin/bash -c "yum install -y mount;
                                  mount -o remount,rw /sys ; 
                                  echo never > /sys/kernel/mm/transparent_hugepage/enabled ;
                                  echo never > /sys/kernel/mm/transparent_hugepage/defrag ;
                                  mount -o remount,ro /sys;
                                  /app/agraph/bin/agraph-control --config /app/agraph/etc/agraph.cfg stop"
# commit a new image with THP disabled
docker commit agraph franzinc/agraph:v6.1.1.THP_disabled
docker stop agraph
docker rm agraph

# Create a Docker volume where AllegroGraph will store its data: 
docker create --name agraph-data-$KB_KEY franzinc/agraph-data

# Create a Docker volume where load requests can be placed
docker create -v /ag-load-requests --name ag-load-requests-$KB_KEY ubuntu:latest

# Build the Docker image (this will import the AllegroGraph Docker image): 
docker build -t ccp/agraph:v6.1.1 allegrograph/build/

# Create a dedicated network so that other containers can talk to the agraph container
docker network create agraph-net-$KB_KEY

# Start up AllegroGraph; monit port is 2812
docker run -d -p 10000-$PLATFORM_ALLEGROGRAPH_PORT:10000-$PLATFORM_ALLEGROGRAPH_PORT \
       --net agraph-net-$KB_KEY \
       --volumes-from agraph-data-$KB_KEY --volumes-from kabob_data-$KB_KEY --volumes-from ag-load-requests-$KB_KEY \
       --name agraph-$KB_KEY ccp/agraph:v6.1.1

# Log the AllegroGraph port to the ag-load-requests directory
docker exec agraph /bin/bash -c "echo $PLATFORM_ALLEGROGRAPH_PORT > /ag-load-requests/agraph.port"

