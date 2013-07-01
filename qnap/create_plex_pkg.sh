#!/bin/sh

if [[ $PLEX_CONFIG == debian-i686 || $PLEX_CONFIG == synology-arm ]];
then
  echo "build QNAP package"
  PLEX_SHORT_VERSION=${PLEX_VERSION:0:10}
  cat qpkg.cfg.in |sed "s|@PLEX_VERSION@|$PLEX_SHORT_VERSION|g;s|@PLEX_SRCDIR@|$PLEX_SRCDIR|g" > qnap-files/qpkg.cfg
  pushd qnap-files
  if [[ $PLEX_CONFIG == debian-i686 ]];
  then
    outarch=x86
  else
    outarch=arm-x19
  fi
  /QNAP/QDK_2.2/bin/qbuild -q --build-arch $outarch
  popd
  mv qnap-files/build/PlexMediaServer_${PLEX_SHORT_VERSION}_${outarch}.qpkg $PLEX_OUTDIR/PlexMediaServer_${PLEX_VERSION}_${outarch}.qpkg
fi
