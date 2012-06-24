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
chmod -R 750 usr/local/emhttp/plugins/plexmediaserver
 
makepkg -c n $PLX_OUTDIR/PlexMediaServer-$PLX_VERSION-unRAID.txz

rm -rf usr/local/plexmediaserver/*

