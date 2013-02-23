#!/bin/sh

if [ ! -e /apps/plexmediaserver/Binaries/Plex\ Media\ Server ]
then
    apt-get update
    apt-get -y install plexmediaserver-ros6-binaries
    #dpkg -i /tmp/plexmediaserver-ros6-binaries_0.9.7.13.0-ad8288a_amd64.deb
fi

. /apps/plexmediaserver/plexmediaserver_environment
/apps/plexmediaserver/Binaries/Plex\ Media\ Server &

