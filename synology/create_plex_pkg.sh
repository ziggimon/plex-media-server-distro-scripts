#!/bin/sh

if [[ $label == build-linux-synology* ]];
then
  echo "building package for synology"
  # create temporary directory
  mkdir plex_package

  # untar Plex to directory plex_package_temp
  cp -a $PLX_SRCDIR/* plex_package

  # copy desktop files
  cp -R dsm_config plex_package

  cd plex_package
  # tar the full package
  tar czf ../package.tgz *

  # cleanup
  cd ..
  rm -rf plex_package

  # update version
  cp INFO.in INFO
  echo "version=$PLX_VERSION" >> INFO
  if [ $label == "build-linux-synology-arm" ]
  then
    echo "arch=\"88f6281 88f6282\"" >> INFO
  else
    echo "arch=\"x86 cedarview bromolow\"" >> INFO
  fi

  # tar the Synology package
  tar czf $PLX_OUTDIR/PlexMediaServer-$PLX_VERSION.spk INFO PACKAGE_ICON.PNG package.tgz scripts
  rm -f package.tgz INFO
fi

