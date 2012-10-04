#!/bin/sh

if [[ $label == build-linux-control4* ]];
then
  DIRNAME=PlexMediaServer-$PLEX_VERSION-control4-arm
	echo "Building Control4 package"
  ln -s $PLEX_SRCDIR $DIRNAME
  tar -cjf $PLEX_OUTDIR/$DIRNAME.tar.bz2 $DIRNAME
fi

