#!/bin/sh

if [ $PLEX_CONFIG == ubuntu-i686 -o $PLEX_CONFIG == ubuntu-x86_64 ];
then
	echo "Building ASUStor package"
	if [ -d build ]; then
		rm -rf build
	fi
	mkdir build
  
  if [ $PLEX_CONFIG == "ubuntu-i686" ]; then
    ARCH="i386"
  else
    ARCH="x86-64"
  fi
	
	cp -r CONTROL build/
	rm build/CONTROL/config.json.in
	cat CONTROL/config.json.in | sed "s/#VERSION#/$PLEX_VERSION/g" | sed "s/#ARCH#/$ARCH/g" > build/CONTROL/config.json

  chmod 644 build/CONTROL/*
  chmod 755 build/CONTROL/*.sh
  sudo chown -R root.root build/CONTROL

	mkdir build/plexmediaserver
	cp -r $PLEX_SRCDIR/* build/plexmediaserver
	python2.7 bin/apkg-tools.py create --destination $PLEX_OUTDIR build
	sudo rm -rf build
fi

