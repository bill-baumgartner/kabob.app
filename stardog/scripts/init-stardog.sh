#!/bin/bash
#
# This script starts stardog, then outputs the stardog log to
# console so that 'docker logs' will return show what's in the agraph
# log. This script also catches the KILL signal when `docker
# stop` is called, allowing stardog to be shutdown gracefully
#

function print_usage {
    echo "Usage:"
    echo "$(basename $0) [OPTIONS]"
    echo "  [-p <stardog-port>]: The port to use when starting stardog"
}

while getopts "k:p:h" OPTION; do
    case ${OPTION} in
        # StarDog port
        p) STARDOG_PORT=$OPTARG
           ;;
        # HELP!
        h) print_usage; exit 0
           ;;
    esac
done

if [[ -z ${STARDOG_PORT} ]]; then
    print_usage
    exit 1
fi


# catch the termination signal and call a script to stop all monitored processes gracefully
trap '/stardog-${STARDOG_VERSION}/bin/stardog-admin server stop ; exit' 15

# start stardog
#CMD borrowed from: https://hub.docker.com/r/nice/ld-docker-stardog/~/dockerfile/
rm -f ${STARDOG_HOME}/system.lock || true && \
    cp /stardog-${STARDOG_VERSION}/stardog-license-key.bin ${STARDOG_HOME} && \
    cp /stardog-${STARDOG_VERSION}/stardog.properties ${STARDOG_HOME} && \
    /stardog-${STARDOG_VERSION}/bin/stardog-admin server start --port ${STARDOG_PORT} && \
    sleep 1 && \
    (tail -f ${STARDOG_HOME}/stardog.log &) && \
    while (pidof java > /dev/null); do sleep 1; done


