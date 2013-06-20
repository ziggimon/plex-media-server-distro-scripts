#!/bin/sh

if [[ $PLEX_CONFIG == debian-i686 ]];
then
  echo "build QNAP package"
  PLEX_SHORT_VERSION=${PLEX_VERSION:0:10}
  cat qpkg.cfg.in |sed "s|@PLEX_VERSION@|$PLEX_SHORT_VERSION|g;s|@PLEX_SRCDIR@|$PLEX_SRCDIR|g" > qnap-files/qpkg.cfg
  pushd qnap-files
  /QNAP/QDK_2.2/bin/qbuild -q --build-arch x86
  popd
  mv qnap-files/build/PlexMediaServer_${PLEX_SHORT_VERSION}_x86.qpkg $PLEX_OUTDIR/PlexMediaServer_${PLEX_VERSION}_x86.qpkg
fi
