#!/bin/bash
#
# This script starts virtuoso, then outputs the virtuoso log to
# console so that 'docker logs' will return show what's in the virtuoso
# log. This script also catches the KILL signal when `docker
# stop` is called, allowing virtuoso to be shutdown gracefully
#

# catch the termination signal and call a script to stop all monitored processes gracefully
trap 'su virtuoso -c "/opt/virtuoso6/bin/isql 1111 dba <password> -K" ; exit' 15

# start allegrograph
#chown virtuoso:virtuoso /data
#su virtuoso -c "/virtuoso.sh"
/virtuoso.sh

# keep the process alive indefinitely
tail -f /usr/local/virtuoso-opensource/var/lib/virtuoso/db/virtuoso.log


