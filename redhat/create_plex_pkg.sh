#!/bin/sh

if [[ Linux-redhat6 == Linux-redhat* ]]; then
	mkdir redhat_temp
	cd redhat_temp
	cp -r ../files/etc ../files/lib ../files/plexmediaserver.spec ../files/usr .
	cp -r ${PLX_SRC}/* usr/lib/plexmediaserver/.
	find ./usr/lib/plexmediaserver/ -type d | cut -d. -f2- | sed 's/\/usr/%dir "\/usr/g' | sed 's/$/"/' >> plexmediaserver.spec
	find ./usr/lib/plexmediaserver/ -type f | cut -d. -f2- | sed 's/$/"/' | sed 's/\/usr/"\/usr/g' >> plexmediaserver.spec
	dir=`pwd`
	cat plexmediaserver.spec | sed "s=^Buildroot:.*$=Buildroot: $dir=g" | sed "s/^Version:.*$/Version: ${PLX_VERSION}/g" | sed "s/^Release:.*$/Release: ${BUILD_NUMBER}/g" > ../plexmediaserver-${PLX_VERSION}.spec
	rm -f plexmediaserver.spec
	cd ..
	rpmbuild -bb --buildroot=${dir} --quiet plexmediaserver-${PLX_VERSION}.spec
	mv *.rpm out/.
	rm -f *.spec
fi
