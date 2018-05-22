#!/bin/bash
#
# This script creates a copy of the agraph.cfg file that comes with
# the agraph distribution and appends the license header to it. This
# file is stored in /config and is referenced in the Dockerfile CMD
# which starts AG.
#

source /config/user-env.sh
PORT_MINUS_ONE=`expr $PLATFORM_ALLEGROGRAPH_PORT - 1`
content=$(cat /data/etc/agraph.cfg)
echo -en "$AG_LICENSE_HEADER\n$content\nSuperUser ${AG_USERPASS}" > /config/agraph.cfg
#sed -i 's/SuperUser test:xyzzy/SuperUser '"$AG_USERPASS"'/g' /config/agraph.cfg
sed -i 's/Port 10035/Port '"$PLATFORM_ALLEGROGRAPH_PORT"'/g' /config/agraph.cfg
sed -i 's/SessionPorts 10000-10034/SessionPorts 10000-'"$PORT_MINUS_ONE"'/g' /config/agraph.cfg
