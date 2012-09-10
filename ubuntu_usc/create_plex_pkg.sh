#!/bin/sh

if [[ $label == build-linux-ubuntu* ]];
then
  ARCH=`dpkg-architecture -qDEB_BUILD_ARCH`
  DIRNAME=PlexMediaServer-$PLX_VERSION-$ARCH-USC
	echo "Building Ubuntu USC package"
	rm -f *.deb *.changes
	mkdir $DIRNAME
	cd $DIRNAME
  ln -s $PLX_SRCDIR $ARCH
  cp -r ../debian ../icons .
  cd ..
  zip -r $PLX_OUTDIR/$DIRNAME.zip $DIRNAME
  rm -rf $DIRNAME
fi

