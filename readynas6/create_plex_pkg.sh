#!/bin/sh

DIRECTORY=PlexMediaServer-$PLEX_VERSION/apps/plexmediaserver

if [ $PLEX_CONFIG == ubuntu-x86_64 ];
then
	echo "Building ReadyNAS 6 package"
	rm -f *.deb *.changes
	mkdir -p $DIRECTORY
    cp -r readynas-files/* $DIRECTORY
    cp -r debian PlexMediaServer-$PLEX_VERSION
	cp -r $PLEX_SRCDIR $DIRECTORY/Binaries
    cd PlexMediaServer-$PLEX_VERSION
	export EMAIL="jenkins@plexapp.com"
	export NAME="Plex CI Team"
	dch -b -v $PLEX_VERSION "Automatic build $BUILD_NUMBER"
	fakeroot dpkg-buildpackage -us -uc -b
	cd ..
	mv *.deb *.changes $PLEX_OUTDIR
	rm -rf PlexMediaServer-$PLEX_VERSION
fi

