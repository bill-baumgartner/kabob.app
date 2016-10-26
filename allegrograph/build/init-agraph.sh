#!/bin/bash
#
# This script starts allegrograph, then outputs the agraph log to
# console so that 'docker logs' will return show what's in the agraph
# log. This script also catches the KILL signal when `docker
# stop` is called, allowing allegrograph to be shutdown gracefully
#

# catch the termination signal and call a script to stop all monitored processes gracefully
trap 'su agraph -c "/app/agraph/bin/agraph-control --config /config/agraph.cfg stop" ; exit' 15

# start allegrograph
chown agraph:agraph /data
su agraph -c "/app/agraph/bin/agraph-control --config /config/agraph.cfg start"

# keep the process alive indefinitely
tail -f /data/log/agraph.log


