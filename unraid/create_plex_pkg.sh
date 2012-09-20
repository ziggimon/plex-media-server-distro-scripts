#!/bin/sh

if [ $PLEX_CONFIG == slackware-i686 ];
then
	export PATH=$PATH:/sbin:/usr/sbin
	echo "Building unRAID package"
	cd plex_package
	rm -rf usr/local/plexmediaserver
	mkdir -p usr/local/plexmediaserver

	#copy source to the right place
	mkdir -p usr/local/plexmediaserver/
	cp -R $PLEX_SRCDIR/* usr/local/plexmediaserver/
	
	#chown -R root:root *
	#chmod -R 750 usr/local/emhttp/plugins/plexmediaserver
	sudo makepkg -c y $PLEX_OUTDIR/PlexMediaServer-$PLEX_VERSION-unRAID.txz
	
	#clean 
	cd ../
	sudo rm -rf plex_package
	git checkout plex_package
fi

