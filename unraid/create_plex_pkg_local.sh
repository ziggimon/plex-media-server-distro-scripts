#!/bin/sh

PLX_VERSION=$1
PLX_SRCDIR="/tmp/PlexMediaServer-$PLX_VERSION"
PLX_OUTDIR="/tmp"

echo "Building unRAID package"
cd plex_package
rm -rf usr/local/plexmediaserver/*

#copy source to the right place
cp -R $PLX_SRCDIR/* usr/local/plexmediaserver/
chown -R root:root *
chmod -R 755 *
chmod -R 777 usr/local/plexmediaserver/
 
makepkg -c n $PLX_OUTDIR/PlexMediaServer-$PLX_VERSION-unRAID.txz

rm -rf usr/local/plexmediaserver/*

chown -R nobody:users ../plex_package
