#!/bin/sh

if [ $PLEX_CONFIG == droboarm ];
then
  echo "Building Drobo package"
  
  # Make the structure.
  cd plex
  mkdir Application

  # Copy application files over.
  cp -R $PLEX_SRCDIR/* Application/
  
  # Tweak version.
  sed -i '/s/--VERSION--/$PLEX_VERSION/g' service.sh
  
  # Fix permissions.
  chown -R root:root plex

  # Finalize package.
  

  # Clean up.
  cd ../
  sudo rm -rf plex
  git checkout plex
fi

