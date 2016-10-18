#!/bin/bash
#
# This script creates a copy of the agraph.cfg file that comes with
# the agraph distribution and appends the license header to it. This
# file is stored in /config and is referenced in the Dockerfile CMD
# which starts AG.
#

source /config/user-env.sh
content=$(cat /app/agraph/etc/agraph.cfg)
echo -en "$AG_LICENSE_HEADER\n$content" > /config/agraph.cfg
