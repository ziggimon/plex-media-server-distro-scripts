#!/bin/sh

if [ $PLEX_CONFIG == ubuntu-x86_64 ];
then
	echo "Building ASUStor package"
	if [ -d build ]; then
		rm -rf build
	fi
	mkdir build
	
	cp -r CONTROL build/
	rm build/CONTROL/config.json.in
	cat CONTROL/config.json.in | sed "s/#VERSION#/$PLEX_VERSION/g" > build/CONTROL/config.json
	mkdir build/plexmediaserver
	cp -r $PLEX_SRCDIR/* build/plexmediaserver
	bin/apkg_build build $PLEX_OUTDIR
	rm -rf build
fi

