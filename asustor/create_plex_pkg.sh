#!/bin/sh

if [ $PLEX_CONFIG == ubuntu-i686 -o $PLEX_CONFIG == ubuntu-x86_64 ];
then
	echo "Building ASUStor package"
	if [ -d build ]; then
		rm -rf build
	fi
	mkdir build
  
  if [ $PLEX_CONFIG == "ubuntu-i686" ]; then
    ARCH="i386"
  else
    ARCH="x86_64"
  fi
	
	cp -r CONTROL build/
	rm build/CONTROL/config.json.in
	cat CONTROL/config.json.in | sed "s/#VERSION#/$PLEX_VERSION/g" | sed "s/#ARCH#/$ARCH/g" > build/CONTROL/config.json
	mkdir build/plexmediaserver
	cp -r $PLEX_SRCDIR/* build/plexmediaserver
	bin/apkg-tools.py create --destination $PLEX_OUTDIR build
	rm -rf build
fi

