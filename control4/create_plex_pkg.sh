#!/bin/sh

if [ $PLEX_CONFIG == "control4-arm" ];
then
  DIRNAME=PlexMediaServer-$PLEX_VERSION-control4-arm
	echo "Building Control4 package"
  ln -s $PLEX_SRCDIR $DIRNAME
  tar -chjf $PLEX_OUTDIR/$DIRNAME.tar.bz2 $DIRNAME
fi

