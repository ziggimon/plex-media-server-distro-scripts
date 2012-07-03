# create plex user if necessary
/bin/id unraid-plex > /dev/null
if  [ $? -ne 0 ]; then
        logger -t plex-install "create user unraid-plex"
        useradd -r -g users -s /sbin/nologin unraid-plex 
        cp /etc/passwd /etc/shadow /boot/config
fi

#source /boot/config/plugins/plexmediaserver/plex_settings.cfg
CONFIG="/boot/config/plugins/plexmediaserver/settings.cfg"

if [ ! -f $CONFIG_FILE ]; then
	
	echo "# Plex Media Server Config file." >> $CONFIG_FILE
	echo "#Set autostart with array" >> $CONFIG_FILE
	echo "ENABLED=\"false\"" >> $CONFIG_FILE
	
	echo "# Set home of Plex Media Server" >> $CONFIG_FILE 
	echo "PLEX_MEDIA_SERVER_HOME=\"/usr/local/plexmediaserver\"" >> $CONFIG_FILE
	
	echo "# Set home for Plex metadata" >> $CONFIG_FILE
	echo "PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=\"/mnt/cache/appdata/plex/Library/Application Support\"" >> $CONFIG_FILE
	
	echo "# the number of plugins that can run at the same time" >> $CONFIG_FILE
	echo "PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6" >> $CONFIG_FILE
	
	echo "# ulimit -s $PLEX_MEDIA_SERVER_MAX_STACK_SIZE" >> $CONFIG_FILE
	echo "PLEX_MEDIA_SERVER_MAX_STACK_SIZE=10000" >> $CONFIG_FILE
	
	echo "# ulimit -l $PLEX_MEDIA_SERVER_MAX_LOCK_MEM" >> $CONFIG_FILE
	echo "PLEX_MEDIA_SERVER_MAX_LOCK_MEM=3000" >> $CONFIG_FILE
	
	echo "# ulimit -n $PLEX_MEDIA_SERVER_MAX_OPEN_FILES" >> $CONFIG_FILE
	echo "PLEX_MEDIA_SERVER_MAX_OPEN_FILES=4096" >> $CONFIG_FILE
	
	echo "# where the mediaserver should store the transcodes" >> $CONFIG_FILE
	echo "PLEX_MEDIA_SERVER_TMPDIR=/tmp" >> $CONFIG_FILE
	
	echo "export LD_LIBRARY_PATH=\"${PLEX_MEDIA_SERVER_HOME}\"" >> $CONFIG_FILE
	echo "export TMPDIR=\"${PLEX_MEDIA_SERVER_TMPDIR}\"" >> $CONFIG_FILE
	echo "export PLEX_MEDIA_SERVER_HOME=$PLEX_MEDIA_SERVER_HOME" >> $CONFIG_FILE
	echo "export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR" >> $CONFIG_FILE
	echo "export PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=$PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS" >> $CONFIG_FILE
	echo "export PLEX_MEDIA_SERVER_TMPDIR=$PLEX_MEDIA_SERVER_TMPDIR" >> $CONFIG_FILE
	echo "export LD_LIBRARY_PATH=$PLEX_MEDIA_SERVER_HOME" >> $CONFIG_FILE
	echo "export LC_ALL=\"en_US.UTF-8\"" >> $CONFIG_FILE
	echo "export LANG=\"en_US.UTF-8\"" >> $CONFIG_FILE
	echo "ulimit -l $PLEX_MEDIA_SERVER_MAX_LOCK_MEM" >> $CONFIG_FILE
	echo "ulimit -s $PLEX_MEDIA_SERVER_MAX_STACK_SIZE" >> $CONFIG_FILE
	echo "ulimit -n $PLEX_MEDIA_SERVER_MAX_OPEN_FILES" >> $CONFIG_FILE
fi


