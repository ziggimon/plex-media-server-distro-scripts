#!/bin/sh

if [[ $NODE_NAME == Linux-Ubuntu* ]];
then
	echo "Building Ubuntu package"
	rm -f *.deb *.changes
	mkdir debian-tmp
	cd debian-tmp
    cp ../plexmediamanager.* .
	ln -s $PLX_SRCDIR src
	cp -r ../debian .
	export EMAIL="jenkins@plexapp.com"
	export NAME="Plex CI Team"
	dch -b -v $PLX_VERSION "Automatic build $BUILD_NUMBER"
	fakeroot dpkg-buildpackage -us -uc -b
	cd ..
    mv debian-tmp PlexMediaServer-$PLX_VERSION-USC
    zip -r PlexMediaServer-$PLX_VERSION-`uname -m`-USC.zip PlexMediaServer-$PLX_VERSION-USC
	mv *.deb *.changes *.zip $PLX_OUTDIR
	rm -rf PlexMediaServer-$PLX_VERSION-USC
fi

