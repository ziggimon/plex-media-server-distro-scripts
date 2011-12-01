#!/bin/sh

if [[ $NODE_NAME == Linux-Ubuntu* ]]
then
	echo "Building Ubuntu package"
	rm -f *.deb *.changes
	mkdir debian-tmp
	cd debian-tmp
	ln -s $PLX_SRCDIR src
	cp -r ../debian .
	export EMAIL="jenkins@plexapp.com"
	export NAME="Plex CI Team"
	dch -b -v $PLX_VERSION "Hudson build $BUILD_NUMBER"
	fakeroot dpkg-buildpackage -us -uc -b
	cd ..
	mv *.deb *.changes $PLX_OUTDIR
	rm -rf debian-tmp
fi

