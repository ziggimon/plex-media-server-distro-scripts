#!/bin/sh

if [[ $label == build-linux-control4* ]];
then
  DIRNAME=PlexMediaServer-$PLX_VERSION-control4-arm
	echo "Building Control4 package"
  ln -s $PLX_SRCDIR $DIRNAME
  tar -cxjf $PLX_OUTDIR/$DIRNAME.tar.bz2 $DIRNAME
fi

