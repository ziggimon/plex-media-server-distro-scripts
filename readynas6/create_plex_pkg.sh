#!/bin/sh

DIRECTORY_META=PlexMediaServer-$PLEX_VERSION/meta/apps/plexmediaserver
DIRECTORY_BIN=PlexMediaServer-$PLEX_VERSION/bin/apps/plexmediaserver

if [ $PLEX_CONFIG == ubuntu-x86_64 ];
then
	echo "Building ReadyNAS 6 package"
	rm -f *.deb *.changes
	mkdir -p $DIRECTORY_META
	mkdir -p $DIRECTORY_BIN
    cp -r readynas-files/* $DIRECTORY_META
    cp -r debian PlexMediaServer-$PLEX_VERSION
	cp -r $PLEX_SRCDIR $DIRECTORY_BIN/Binaries
    cat readynas-files/config.xml | sed s/##VERSION##/$PLEX_VERSION/g > $DIRECTORY_META/config.xml
    cd PlexMediaServer-$PLEX_VERSION
	export EMAIL="jenkins@plexapp.com"
	export NAME="Plex CI Team"
	dch -b -v $PLEX_VERSION "Automatic build $BUILD_NUMBER"
	fakeroot dpkg-buildpackage -us -uc -b
	cd ..
	mv *.deb *.changes $PLEX_OUTDIR
	rm -rf PlexMediaServer-$PLEX_VERSION
fi

