#!/bin/sh

#!/bin/sh -e

if [ ! -e /apps/plexmediaserver/Binaries/Plex\ Media\ Server ]
then
    event_push app readynasd '<command-s resource-type="LocalApp" resource-id="LocalApp"><LocalApp cmdname="apt-get" status="start" appname="Plex Media Ser ver"/></command-s>' 0 0
    systemd-notify STATUS="Run apt-get update ..."
    apt-get update
    systemd-notify STATUS="Installing Plex binaries ..."
    if apt-get -y install plexmediaserver-ros6-binaries; then
        event_push app readynasd '<add-s resource-type="LocalApp" resource-id="LocalApp"><LocalApp appname="Plex Media Server" success="1"/></add-s>' 0 0
    else
        event_push app readynasd '<add-s resource-type="LocalApp" resource-id="LocalApp"><LocalApp appname="Plex Media Server" success="0"/></add-s>' 0 0
    fi
fi

. /apps/plexmediaserver/plexmediaserver_environment

# Make sure that the TMPDIR exists
if [ ! -d $TMPDIR ]
then
    mkdir -p $TMPDIR
fi

systemd-notify READY=1
/apps/plexmediaserver/Binaries/Plex\ Media\ Server

