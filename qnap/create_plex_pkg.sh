#!/bin/sh

if [[ $PLEX_CONFIG == debian-i686 || $PLEX_CONFIG == synology-arm ]];
then
  echo "build QNAP package"
  mkdir src
  cp -R $PLEX_SRCDIR/* src/.
  PLEX_SHORT_VERSION=${PLEX_VERSION:0:10}

  # Define what version to build
  if [[ $PLEX_CONFIG == debian-i686 ]];
  then
    ARCH=X86
  else
    ARCH=X19
  fi
  cat qpkg.cfg.in |sed "s|@PLEX_VERSION@|$PLEX_SHORT_VERSION|g;s|@PLEX_SRCDIR@|../src/|g;s|@ARCH@|$ARCH|g" > qnap-files/qpkg.cfg
  pushd qnap-files

  # Build the packages
  if [[ $PLEX_CONFIG == debian-i686 ]];
  then
    outarch=x86
  else
    outarch=arm-x19
    export LD_LIBRARY_PATH=/QNAP/lib
  fi
  /QNAP/QDK_2.2/bin/qbuild -q --build-arch $outarch
  popd
  mv qnap-files/build/PlexMediaServer_${PLEX_SHORT_VERSION}_${outarch}.qpkg $PLEX_OUTDIR/PlexMediaServer_${PLEX_VERSION}_${outarch}.qpkg
  # Clean up src dir
  rm -rf src
fi
