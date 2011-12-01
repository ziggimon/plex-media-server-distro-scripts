#!/bin/bash

SERVICE=PLEXMEDIASERVER
CONF_FILES="/c/.plex /etc/init.d/plexserver /root/Library"
PROG_FILES="/etc/frontview/apache/addons/PLEXMEDIASERVER.conf* \
            /etc/frontview/addons/*/PLEXMEDIASERVER"

# Stop service from running
eval `awk -F'!!' "/^$SERVICE\!\!/ { print \\$5 }" /etc/frontview/addons/addons.conf`

# Remove program files
if ! [ "$1" = "-upgrade" ]; then
  if [ "$CONF_FILES" != "" ]; then
    for i in $CONF_FILES; do
      rm -rf $i &>/dev/null
    done
  fi
  update-rc.d remove plexserver
fi

if [ "$PROG_FILES" != "" ]; then
  for i in $PROG_FILES; do
    rm -rf $i
  done
fi

# Remove entry from services file
sed -i "/^$SERVICE/d" /etc/default/services

# Remove entry from addons.conf file
sed -i "/^$SERVICE\!\!/d" /etc/frontview/addons/addons.conf

# Remove binaries
rm -f /c/.plex/*

# Reread modified service configuration files
killall -USR1 apache-ssl

# Now remove ourself
rm -f $0

exit 0
