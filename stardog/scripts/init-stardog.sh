#!/bin/bash
#
# This script starts stardog, then outputs the stardog log to
# console so that 'docker logs' will return show what's in the agraph
# log. This script also catches the KILL signal when `docker
# stop` is called, allowing stardog to be shutdown gracefully
#

# catch the termination signal and call a script to stop all monitored processes gracefully
trap '/stardog-${STARDOG_VERSION}/bin/stardog-admin server stop ; exit' 15

# start stardog
#CMD borrowed from: https://hub.docker.com/r/nice/ld-docker-stardog/~/dockerfile/
rm -f ${STARDOG_HOME}/system.lock || true && \
    cp /stardog-${STARDOG_VERSION}/stardog-license-key.bin ${STARDOG_HOME} && \
    cp /stardog-${STARDOG_VERSION}/stardog.properties ${STARDOG_HOME} && \
    /stardog-${STARDOG_VERSION}/bin/stardog-admin server start  && \
    sleep 1 && \
    (tail -f ${STARDOG_HOME}/stardog.log &) && \
    while (pidof java > /dev/null); do sleep 1; done


