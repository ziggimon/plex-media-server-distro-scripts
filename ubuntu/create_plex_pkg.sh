#!/bin/sh

if [[ $NODE_NAME == Linux-Ubuntu* ]];
then
	echo "Building Ubuntu package"
	rm -f *.deb *.changes
	mkdir PlexMediaServer-$PLX_VERSION-USC
	cd PlexMediaServer-$PLX_VERSION-USC
    cp ../plexmediamanager.* .
	ln -s $PLX_SRCDIR src
	cp -r ../debian .
	export EMAIL="jenkins@plexapp.com"
	export NAME="Plex CI Team"
	dch -b -v $PLX_VERSION "Automatic build $BUILD_NUMBER"
    cd ..
    zip -r PlexMediaServer-$PLX_VERSION-`uname -m`-USC.zip PlexMediaServer-$PLX_VERSION-USC
    cd PlexMediaServer-$PLX_VERSION-USC
	fakeroot dpkg-buildpackage -us -uc -b
	cd ..
	mv *.deb *.changes *.zip $PLX_OUTDIR
	rm -rf PlexMediaServer-$PLX_VERSION-USC
fi

