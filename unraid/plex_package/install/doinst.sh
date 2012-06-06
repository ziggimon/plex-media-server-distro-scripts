# create plex user if necessary
/bin/id unraid-plex > /dev/null
if  [ $? -ne 0 ]; then
        logger -t plex-install "create user unraid-plex"
        useradd -r -g users -s /sbin/nologin unraid-plex 
        cp /etc/passwd /etc/shadow /boot/config
fi

#first install copy default settings 
test -e /boot/config/plugins/plexmediaserver/plex_settings.cfg || cp /boot/config/plugins/plexmediaserver/plex_default.cfg /boot/config/plugins/plexmediaserver/plex_settings.cfg

#source /boot/config/plugins/plexmediaserver/plex_settings.cfg

# create Library and change owner if it doens't exist 
#if [ ! -d $DEFAULT_PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR ]; then
#	echo "Create Plex Media Server Library directory"
#	mkdir -p "$DEFAULT_PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/Application Support/"
#	chown -R $DEFAULT_RUNAS:users $DEFAULT_PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR
#else
#if it exist check owner
#	if [ "$(stat -c %U $DEFAULT_PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR)"  != "$DEFAULT_RUNAS" ]; then
#	echo "Change owner of existing Plex Media Server Library directory"
#	chown -R $DEFAULT_RUNAS:users $DEFAULT_PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR
#	fi 
#fi


