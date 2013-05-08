#!/bin/sh

if [ ! -e /apps/plexmediaserver/Binaries/Plex\ Media\ Server ]
then
    apt-get update
    apt-get -y install plexmediaserver-ros6-binaries
fi

. /apps/plexmediaserver/plexmediaserver_environment

# Make sure that the TMPDIR exists
if [ ! -d $TMPDIR ]
then
    mkdir -p $TMPDIR
fi

/apps/plexmediaserver/Binaries/Plex\ Media\ Server &

