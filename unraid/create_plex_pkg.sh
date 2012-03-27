#!/bin/sh

if [[ $NODE_NAME == Linux-Slackware* ]];
then
	echo "Building unRAID package"
  tar -cjf $PLX_OUTDIR/PlexMediaServer-$PLX_VERSION-unRAID.tar.bz2 -C`dirname $PLX_SRCDIR` `basename $PLX_SRCDIR`
fi

