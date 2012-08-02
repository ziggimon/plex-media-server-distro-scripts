#!/bin/sh

if [[ $NODE_NAME == Linux-Slackware* ]];
then
	export PATH=$PATH:/sbin:/usr/sbin
	echo "Building unRAID package"
	cd plex_package
	rm -rf usr/local/plexmediaserver
	mkdir -p usr/local/plexmediaserver

	#copy source to the right place
	mkdir -p usr/local/plexmediaserver/
	cp -R $PLX_SRCDIR/* usr/local/plexmediaserver/
	
	#chown -R root:root *
	#chmod -R 750 usr/local/emhttp/plugins/plexmediaserver
	sudo makepkg -c y $PLX_OUTDIR/PlexMediaServer-$PLX_VERSION-unRAID.txz
	
	#clean 
	sudo rm -rf usr/local/plexmediaserver
fi

