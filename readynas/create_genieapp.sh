#!/bin/sh

PLEX_VERSION=$(scripts/common/make-version-header.py -p)

ROOTDIR=$(pwd)
ADDONFILE=$ROOTDIR/upload/PlexMediaServer-$PLEX_VERSION-arm.bin
ADDONNAME=$(basename $ADDONFILE)
GENIEPATH=$ROOTDIR/scripts/linux/distro-scripts/readynas/genieappcreator/

if [ ! -f $ADDONFILE ]
then
  echo "Could not find $ADDONFILE"
  exit 1
fi

# GenieApps won't allow git revisions, let's remove it
PLEX_VERSION=$(scripts/common/make-version-header.py -pg)

echo "copy"
cp $ADDONFILE $GENIEPATH
cd $GENIEPATH

echo "ant -Daddon=$ADDONNAME -Dversion='$PLEX_VERSION' -propertyfile build.properties"
ant -Daddon=$ADDONNAME -Dversion="$PLEX_VERSION" -propertyfile build.properties
mv plex_plexmediaserver_$PLEX_VERSION.zip $ROOTDIR/upload

#clean up
rm $GENIEPATH/$ADDONNAME
cd $ROOTPATH

