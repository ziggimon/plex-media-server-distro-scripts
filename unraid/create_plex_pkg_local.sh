#!/bin/sh

PLX_VERSION=$1
PLX_SRCDIR="/tmp/PlexMediaServer-$PLX_VERSION/usr/local/plexmediaserver/"
PLX_OUTDIR="/tmp"

echo "Building unRAID package"
cd plex_package
rm -rf usr/local/plexmediaserver
mkdir -p usr/local/plexmediaserver
#copy source to the right place
cp -R $PLX_SRCDIR/* usr/local/plexmediaserver/
 
makepkg -c n $PLX_OUTDIR/PlexMediaServer-$PLX_VERSION-unRAID.txz

#clean 
cd ../
sudo rm -rf plex_package
git checkout plex_package
