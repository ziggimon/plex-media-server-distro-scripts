#!/bin/sh

if [[ $NODE_NAME == Linux-Ubuntu-Lucid-* ]]; then
    echo "build RPM"
    rm -rf redhat_temp
	mkdir redhat_temp
	cd redhat_temp
    mkdir -p usr/lib/plexmediaserver
	cp -r ../files/etc ../files/lib ../files/plexmediaserver.spec ../files/usr .
	cp -r ${PLX_SRCDIR}/* usr/lib/plexmediaserver/.
	find ./usr/lib/plexmediaserver/ -type d | cut -d. -f2- | sed 's/\/usr/%dir "\/usr/g' | sed 's/$/"/' >> plexmediaserver.spec
	find ./usr/lib/plexmediaserver/ -type f | cut -d. -f2- | sed 's/$/"/' | sed 's/\/usr/"\/usr/g' >> plexmediaserver.spec
	DIR=`pwd`
	RPMVERSION=`echo ${PLX_VERSION}| cut -d"-" -f1`
	cat plexmediaserver.spec | sed "s=^Buildroot:.*$=Buildroot: $DIR=g" | sed "s/^Version:.*$/Version: ${rpmversion}/g" | sed "s/^Release:.*$/Release: ${GIT_VERSION}/g" > ../plexmediaserver-${RPMVERSION}.spec
	rm -f plexmediaserver.spec
	cd ..
	rpmbuild -bb --buildroot=${dir} --quiet plexmediaserver-${RPMVERSION}.spec
	mv *.rpm ${PLX_OUTDIR} 
	rm -f *.spec
fi
