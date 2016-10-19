#!/bin/bash

#
# Set up resources, build the custom AllegroGraph image, and start up AllegroGraph
#

if ! [[ -e README.md ]]; then
    echo "Please run from the root of the project."
    exit 1
fi


# Create a Docker volume where AllegroGraph will store its data: 
docker create --name agraph-data franzinc/agraph-data

# Build the Docker image (this will import the AllegroGraph Docker image): 
docker build -t ccp/agraph:v6.1.1 allegrograph/build/

# Populate two Docker volumes and populate with required code:
docker run --rm -v $(pwd):/backup billbaumgartner/kabob-base:0.1 tar czvf /backup/kabob.git-backup.tar.gz /kabob.git
docker create -v /kabob.git --name kabob.git ubuntu:latest
docker run --rm --volumes-from kabob.git -v $(pwd):/backup ubuntu:latest bash -c "cd /kabob.git && tar xzvf /backup/kabob.git-backup.tar.gz --strip 1"
rm kabob.git-backup.tar.gz

docker run --rm -v $(pwd):/backup billbaumgartner/kabob-base:0.1 tar czvf /backup/m2-backup.tar.gz /root/.m2
docker create -v /root/.m2 --name m2 ubuntu:latest
docker run --rm --volumes-from m2 -v $(pwd):/backup ubuntu bash -c "cd /root/.m2 && tar xzvf /backup/m2-backup.tar.gz --strip 2"
rm m2-backup.tar.gz

# Start up AllegroGraph
docker run -d -p 10000-10035:10000-10035 \
   --volumes-from agraph-data --volumes-from kabob_data --volumes-from kabob.git --volumes-from m2 \
   --name agraph ccp/agraph:v6.1.1

