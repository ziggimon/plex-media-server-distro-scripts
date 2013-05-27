#!/bin/sh

# disable it for now
exit 0

if [[ $PLEX_CONFIG == debian-i686 ]];
then
	echo "build QNAP package"
	
	if test -d qnap-chroot
	then
		cd qnap-chroot
		git fetch
		git reset --hard origin/master
		sudo rm -rf plex/build
		cd ..
	else
		git clone git@github.com:plexinc/qnap-chroot
		mkdir -p qnap-chroot/dev qnap-chroot/proc
	fi
	test -e qnap-chroot/dev/null || sudo mount -o bind /dev qnap-chroot/dev
	test -e qnap-chroot/proc/1 || sudo mount -o bind /proc qnap-chroot/proc

	rm -rf qnap-chroot/plex/x86
	mkdir -p qnap-chroot/plex/x86
	cp -a $PLEX_SRCDIR/* qnap-chroot/plex/x86
  cp -a qnap-chroot/plex/x86_template/* qnap-chroot/plex/x86
	sudo cp qpkg.cfg.in qnap-chroot/plex/qpkg.cfg
	echo "QPKG_VER=\"$PLEX_VERSION\"" | sudo tee -a qnap-chroot/plex/qpkg.cfg
	sudo chroot qnap-chroot /build-pkg.sh
	sudo mv qnap-chroot/plex/build/* $PLEX_OUTDIR
	sudo chown -R plex.plex $PLEX_OUTDIR

  sudo umount qnap-chroot/dev
  sudo umount qnap-chroot/proc

fi


