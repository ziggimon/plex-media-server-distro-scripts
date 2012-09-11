#!/bin/sh

if [ $PLEX_CONFIG == ubuntu-i686 -o $PLEX_CONFIG == ubuntu-amd64 ];
then
  ARCH=`dpkg-architecture -qDEB_BUILD_ARCH`
  DIRNAME=PlexMediaServer-$PLEX_VERSION-$ARCH-USC
	echo "Building Ubuntu USC package"
	rm -f *.deb *.changes
	mkdir $DIRNAME
	cd $DIRNAME
  ln -s $PLEX_SRCDIR $ARCH
  cp -r ../debian ../icons .
  cd ..
  zip -r $PLEX_OUTDIR/$DIRNAME.zip $DIRNAME
  rm -rf $DIRNAME
fi

