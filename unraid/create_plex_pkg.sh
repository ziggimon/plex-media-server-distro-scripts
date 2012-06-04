#!/bin/sh

if [[ $NODE_NAME == Linux-Slackware* ]];
then
	export PATH=$PATH:/sbin:/usr/sbin
	echo "Building unRAID package"
	cd plex_package
	rm -rf usr/local/plexmediaserver/*
	mkdir -p usr/local/plexmediaserver

	#copy source to the right place
	cp -R $PLX_SRCDIR/* usr/local/plexmediaserver/
	sudo chown -R root:root *
	sudo chmod -R 755 *
	sudo chmod -R 777 usr/local/plexmediaserver/
	 
	makepkg -c n $PLX_OUTDIR/PlexMediaServer-$PLX_VERSION-unRAID.txz
	
	#clean 
	rm -rf usr/local/plexmediaserver/*
	chown nobody:users ../plex_package
fi

