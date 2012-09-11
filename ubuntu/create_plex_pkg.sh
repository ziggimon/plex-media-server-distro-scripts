#!/bin/sh

if [ $PLEX_CONFIG == ubuntu-i686 -o $PLEX_CONFIG == ubuntu-amd64 ];
then
	echo "Building Ubuntu package"
	rm -f *.deb *.changes
	mkdir PlexMediaServer-$PLEX_VERSION
	cd PlexMediaServer-$PLEX_VERSION
    cp ../plexmediamanager.* .
    cp ../plexmediaserver.list . 
    cp ../plex-archive-keyring.gpg . 
	ln -s $PLEX_SRCDIR src
	cp -r ../debian .
	export EMAIL="jenkins@plexapp.com"
	export NAME="Plex CI Team"
	dch -b -v $PLEX_VERSION "Automatic build $BUILD_NUMBER"
	fakeroot dpkg-buildpackage -us -uc -b
	cd ..
	mv *.deb *.changes *.zip $PLEX_OUTDIR
	rm -rf PlexMediaServer-$PLEX_VERSION
fi

