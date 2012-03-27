#!/bin/sh

if [[ $NODE_NAME == Synology* ]];
then
  echo "building package for synology"
  # create temporary directory
  mkdir plex_package

  # untar Plex to directory plex_package_temp
  cp -a $PLX_SRCDIR/* plex_package

  # copy desktop files
  cp -R dsm_config plex_package

  # for synology we want to use the non-jemalloc binaries
  cp plex_package/Plex\ Media\ Server-nojemalloc plex_package/Plex\ Media\ Server
  cp plex_package/Plex\ Media\ Scanner-nojemalloc plex_package/Plex\ Media\ Scanner

  cd plex_package
  # tar the full package
  tar czf ../package.tgz *

  # cleanup
  cd ..
  rm -rf plex_package

  # update version
  cp INFO.in INFO
  echo "version=$PLX_VERSION" >> INFO

  # tar the Synology package
  tar czf $PLX_OUTDIR/PlexMediaServer-$PLX_VERSION.spk INFO PACKAGE_ICON.PNG package.tgz scripts
  rm -f package.tgz INFO
fi

