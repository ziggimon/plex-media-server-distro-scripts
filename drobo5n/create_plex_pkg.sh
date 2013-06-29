#!/bin/sh

if [ $PLEX_CONFIG == drobo-arm ];
then
  echo "Building Drobo package"
  
  # Make the structure.
  cd plex
  mkdir Application
  mkdir Library

  # Copy application files over.
  cp -R $PLEX_SRCDIR/* Application/
  
  # Tweak version.
  sed -i "s/##VERSION##/$PLEX_VERSION/g" service.sh
  
  # Fix permissions.
  cd ..
  sudo chown -R root:root plex

  # Finalize package.
  cd plex
  rm ../plex.tgz
  tar cfvz $PLEX_OUTDIR/plex.tgz .

  # Clean up.
  cd ..
  sudo rm -rf plex
  git checkout plex
fi

