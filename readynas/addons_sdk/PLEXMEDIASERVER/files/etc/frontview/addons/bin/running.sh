#!/bin/bash
#
# This script returns 0 if service is running, 1 otherwise.
#
# UNCOMMENT and MODIFY as necessary; return 1 for now.
#

if [ -f /var/run/plexserver.pid ]; then
    exit 0
fi

exit 1
