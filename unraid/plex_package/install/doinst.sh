#!/bin/bash

CONFIG_FILE="/boot/config/plugins/plexmediaserver/settings.ini"
PLEX_MEDIA_SERVER_HOME="/usr/local/plexmediaserver"
UNRAID_PLEX_GUI="/usr/local/emhttp/plugins/plexmediaserver"

#create plex user if necessary
/bin/id unraid-plex > /dev/null
if  [ $? -ne 0 ]; then
        logger -t pms "create user unraid-plex"
        useradd -r -g users -s /sbin/nologin unraid-plex
        cp /etc/passwd /etc/shadow /boot/config
fi


if [ ! -f $CONFIG_FILE ]; then
		logger -t pms "creating default config file ($CONFIG_FILE)"
		
        echo "#[PMS Settings]" >> $CONFIG_FILE
        echo "#START_CONFIGURATION" >> $CONFIG_FILE
        echo "#Set autostart with array" >> $CONFIG_FILE
        echo "ENABLED=\"false\"" >> $CONFIG_FILE
        echo "RUNAS=\"unraid-plex\"" >> $CONFIG_FILE
        echo "#Set home of Plex Media Server" >> $CONFIG_FILE
        echo "PLEX_MEDIA_SERVER_HOME=\"$PLEX_MEDIA_SERVER_HOME\"" >> $CONFIG_FILE
        echo "#Set home for Plex metadata" >> $CONFIG_FILE
        echo "PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=\"/tmp/Library\"" >> $CONFIG_FILE
        echo "#the number of plugins that can run at the same time" >> $CONFIG_FILE
        echo "PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6" >> $CONFIG_FILE
        echo "#ulimit -s $PLEX_MEDIA_SERVER_MAX_STACK_SIZE" >> $CONFIG_FILE
        echo "PLEX_MEDIA_SERVER_MAX_STACK_SIZE=10000" >> $CONFIG_FILE
        echo "#ulimit -l $PLEX_MEDIA_SERVER_MAX_LOCK_MEM" >> $CONFIG_FILE
        echo "#PLEX_MEDIA_SERVER_MAX_LOCK_MEM=3000" >> $CONFIG_FILE
        echo "#ulimit -n $PLEX_MEDIA_SERVER_MAX_OPEN_FILES" >> $CONFIG_FILE
        echo "PLEX_MEDIA_SERVER_MAX_OPEN_FILES=4096" >> $CONFIG_FILE
        echo "#where the mediaserver should store the transcodes" >> $CONFIG_FILE
        echo "PLEX_MEDIA_SERVER_TMPDIR=\"/tmp\"" >> $CONFIG_FILE
        echo "#STOP_CONFIGURATION" >> $CONFIG_FILE
fi

if [ -f /boot/config/plugins/plexmediaserver/plex_settings.cfg ];then
		logger -t pms "converting old config file into the new"
        source /boot/config/plugins/plexmediaserver/plex_settings.cfg
        sed -i "/START_CONFIGURATION/,/STOP_CONFIGURATION/ {
                /ENABLED/ c\ENABLED=\"$DEFAULT_ENABLED\"
                /PLEX_MEDIA_SERVER_TMPDIR/ c\PLEX_MEDIA_SERVER_TMPDIR=\"$DEFAULT_TMPDIR\"
                /PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/ c\PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=\"$DEFAULT_PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR\"
        }
        " $CONFIG_FILE
        rm -f /boot/config/plugins/plexmediaserver/plex_settings.cfg
fi

#set permissions
chown -R root:root $PLEX_MEDIA_SERVER_HOME
chown -R root:root $UNRAID_PLEX_GUI
chown -R root:root /etc/rc.d/rc.plexmediaserver