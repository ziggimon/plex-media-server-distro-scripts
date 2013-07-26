#!/bin/bash

if [ $BUILD_TAG == freebsd-x86_64 ]; then
    echo "build BSD tar.bz2"
    rm -rf freebsd_temp
    mkdir freebsd_temp
    cd freebsd_temp
    RELEASE=`echo ${PLEX_VERSION}| cut -d"-" -f1`
    GIT_VERSION=`echo ${PLEX_VERSION} | cut -d"-" -f2`
    mkdir -p PlexMediaServer-${RELEASE}-${GIT_VERSION}
    cp -r ${PLEX_SRCDIR}/* PlexMediaServer-${RELEASE}-${GIT_VERSION}
    tar cjf PlexMediaServer-${RELEASE}-${GIT_VERSION}.tar.bz2 PlexMediaServer-${RELEASE}-${GIT_VERSION}
    mv PlexMediaServer-${RELEASE}-${GIT_VERSION}.tar.bz2 ${PLEX_OUTDIR}/.
fi
