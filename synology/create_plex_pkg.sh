#!/bin/sh

if [[ $PLEX_CONFIG == synology-* ]];
then
  echo "building package for synology"
  # create temporary directory
  mkdir plex_package

  # untar Plex to directory plex_package_temp
  cp -a $PLEX_SRCDIR/* plex_package

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
  outarch="noarch"
  echo "version=$PLEX_VERSION" >> INFO
  if [ $PLEX_CONFIG == "synology-arm" ]
  then
    echo "arch=\"88f6281 88f6282\"" >> INFO
    outarch="arm"
  elif [ $PLEX_CONFIG == "synology-arm7" ]
  then
    echo "arch=\"armada370 armadaxp\"" >> INFO
    outarch="arm7"
  elif [ $PLEX_CONFIG == "synology-ppc" ]
  then
    echo "arch=\"qoriq\"" >> INFO
    outarch="ppc_qoriq"
  else
    echo "arch=\"x86 cedarview bromolow evansport\"" >> INFO
    outarch="x86"
  fi

  # tar the Synology package
  tar cf $PLEX_OUTDIR/PlexMediaServer-$PLEX_VERSION-$outarch.spk INFO PACKAGE_ICON.PNG package.tgz scripts
  rm -f package.tgz INFO
fi

