#!/bin/bash

ADDON_HOME=/etc/frontview/addons

bye() {
  . /frontview/bin/functions
  cd /
  rm -rf $orig_dir
  echo -n ": $1 "
  log_status "$1" 1

  exit 1
}

orig_dir=`pwd`
name=`awk -F'!!' '{ print $1 }' addons.conf`
stop=`awk -F'!!' '{ print $5 }' addons.conf`
run=`awk -F'!!' '{ print $4 }' addons.conf`
version=`awk -F'!!' '{ print $3 }' addons.conf`

if grep -q ${name} $ADDON_HOME/addons.conf; then
  orig_vers=`awk -F'!!' '/PLEXMEDIASERVER/ { print $3 }' $ADDON_HOME/addons.conf | cut -f1 -d'.'`
fi

[ -z "$name" ] && bye "ERROR: No addon name!"

# Remove old versions of our addon
if [ -f "$ADDON_HOME/${name}.remove" ]; then
  sh $ADDON_HOME/${name}.remove -upgrade &>/dev/null
fi

###########  Addon specific action go here ###########

raidiator_version=`sed -e 's/.*version=//' -e 's/,.*//' -e 's/-.*//' /var/log/raidiator_version`
raidiator_version_ver=${raidiator_version%.*}
raidiator_version_patch=${raidiator_version##*.}
if [ "$raidiator_version_ver" != "4.2" -o "$raidiator_version_patch" == "" -o $raidiator_version_patch -lt 15 ]; then
  bye "$LINENO: ERROR: Plex Media Server (x86) can apply on only 4.2.15 or later"
fi

LIBLINK=`readlink /root/Library`
if [ "$LIBLINK" = "" ]; then
    # not symlinked so we may need to move it
    if [ -d /root/Library ]; then
	# we really have a directory already
	mkdir -p /c/.plex
	cd /root
	mv Library /c/.plex/
	ln -s /c/.plex/Library
	cd -
    else
	mkdir -p /c/.plex/Library
	cd /root
	ln -fs /c/.plex/Library
	cd -
    fi
fi

###########  Addon specific action go here ###########

# Extract program files
cd / || bye "ERROR: Could not change working directory."
tar xfz $orig_dir/files.tgz || bye "ERROR: Could not extract files properly."

# Add ourself to the main addons.conf file
[ -d $ADDON_HOME ] || mkdir $ADDON_HOME
chown -R admin.admin $ADDON_HOME
grep -v i"^$name!!" $ADDON_HOME/addons.conf >/tmp/addons.conf$$ 2>/dev/null
cat $orig_dir/addons.conf >>/tmp/addons.conf$$ || bye "ERROR: Could not include addon configuration."
cp /tmp/addons.conf$$ $ADDON_HOME/addons.conf || bye "ERROR: Could not update addon configuration."
rm -f /tmp/addons.conf$$ || bye "ERROR: Could not clean up."

# Copy our removal script to the default directory
cp $orig_dir/remove.sh $ADDON_HOME/${name}.remove

# Turn ourselves on in the services file
grep -v "$name[_=]" /etc/default/services >/tmp/services$$ || bye "ERROR: Could not back up service configuration."
echo "${name}_SUPPORT=1" >>/tmp/services$$ || bye "ERROR: Could not add service configuration."
echo "${name}=1" >>/tmp/services$$ || bye "ERROR: Could not add service configuration."
cp /tmp/services$$ /etc/default/services || bye "ERROR: Could not update service configuration."
rm -f /tmp/services$$ || bye "ERROR: Could not clean up."


###########  Addon specific action go here ###########

# create our destination directory
mkdir -p /c/.plex/tmp

# create a temp dir for unpacking
mkdir -p /c/.plex_unpack

# go there and unpack our stuff
cd /c/.plex_unpack
for myfile in /tmp/rnxtmp/*.tar.bz2; do
    tar xfj $myfile
done
cd -

# remove our archive dir
rm -rf /tmp/rnxtmp

# remove original binaries for good measure
rm -f /c/.plex/*
rm -rf /c/.plex/Resources

# move the files
for mydir in /c/.plex_unpack/Plex*; do
    mv -fv $mydir/* /c/.plex/
done
cd /c/.plex
# rm -f libavahi*
rm -f plexserver
ln -s Plex\ Media\ Server plexserver
# need to change ownership here to make things accessible
# from the ReadyNAS web interface
chown -R admin:admin .
cd -

#remove the unpack dir
rm -rf /c/.plex_unpack

# fix permission issues
chown -R root:root /c/.plex
chmod -R 755 /c/.plex

# clean out some old stuff if it exists
[ -e "/etc/frontview/addons/PLEXNINESERVER.remove" ] && rm -rf /etc/frontview/addons/PLEXNINESERVER.remove

# Check for existence of Frontview UI for old add-on name and if so remove
[ -d /etc/frontview/addons/ui/PLEXNINESERVER ] && rm -rf /etc/frontview/addons/*/PLEXNINESERVER
[ -e "/etc/frontview/apache/addons/PLEXNINESERVER.conf" ] && rm -rf /etc/frontview/apache/addons/PLEXNINESERVER.conf*

OLDSERVICE=PLEXNINESERVER
# Remove entry from services file
sed -i "/^$OLDSERVICE/d" /etc/default/services
# Remove entry from addons.conf file
sed -i "/^$OLDSERVICE\!\!/d" /etc/frontview/addons/addons.conf


######################################################

eval $run

friendly_name=`awk -F'!!' '{ print $2 }' $orig_dir/addons.conf`

# Remove the installation files
cd /
rm -rf $orig_dir

exit 0
