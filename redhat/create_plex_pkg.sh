#!/bin/sh

if [ $PLEX_CONFIG == ubuntu-i686 -o $PLEX_CONFIG == ubuntu-x86_64 ]; then
    echo "build RPM"
    rm -rf redhat_temp
    mkdir redhat_temp
    cd redhat_temp
    mkdir -p usr/lib/plexmediaserver
    cp -r ../files/etc ../files/lib ../files/plexmediaserver.spec ../files/usr .
    cp -r ${PLEX_SRCDIR}/* usr/lib/plexmediaserver/.
    DIR=`pwd`
    RPMVERSION=`echo ${PLEX_VERSION}| cut -d"-" -f1`
    GIT_VERSION=`echo ${PLEX_VERSION} | cut -d"-" -f2`
    cat plexmediaserver.spec | sed "s=^Buildroot:.*$=Buildroot: $DIR=g" | sed "s/^Version:.*$/Version: ${RPMVERSION}/g" | sed "s/^Release:.*$/Release: ${GIT_VERSION}/g" > ../plexmediaserver-${RPMVERSION}.spec
    rm -f plexmediaserver.spec
    cd ..
    rpmbuild -bb --buildroot=${DIR} --verbose plexmediaserver-${RPMVERSION}.spec
    mv ../*.rpm ${PLEX_OUTDIR} 
    rm -f *.spec
fi
