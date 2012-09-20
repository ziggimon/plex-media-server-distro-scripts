#!/bin/sh

# the number of plugins that can run at the same time
export PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6

# ulimit -s $PLEX_MEDIA_SERVER_MAX_STACK_SIZE
export PLEX_MEDIA_SERVER_MAX_STACK_SIZE=3000

# where the mediaserver should store the transcodes
export PLEX_MEDIA_SERVER_TMPDIR=/tmp
export TMPDIR=$PLEX_MEDIA_SERVER_TMPDIR

# root of the plex application
export PLEX_MEDIA_SERVER_ROOT="/usr/local/AppCentral/plexmediaserver/plexmediaserver"

# uncomment to set it to something else
export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/volume1/Plex/Library"

# set the library path to the root directory
export LD_LIBRARY_PATH=$PLEX_MEDIA_SERVER_ROOT

# use a default locale that we are sure is around
export LC_CTYPE=C

# plex pid file path
export PLEX_PID_PATH="$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/Plex Media Server/plexmediaserver.pid"

check_asdir() {
	if [ ! -d "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR" ]
	then
	    mkdir -p "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR"
	  	if [ ! $? -eq 0 ]
	    then
		    echo "WARNING COULDN'T CREATE $PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR, MAKE SURE I HAVE PERMISSON TO DO THAT!"
		    return 1
	    fi
	fi
    return 0
}

do_start() {
    check_asdir()
    ulimit -s $PLEX_MEDIA_SERVER_MAX_STACK_SIZE
    (cd $PLEX_MEDIA_SERVER_ROOT ; ./Plex\ Media\ Server &)
    return 0
}

do_stop() {
    # Kill Plex.
    if [ -f "$PLEX_PID_PATH" ]
    then
        kill `cat "$PLEX_PID_PATH"`
    fi
    return 0
}

case "$1" in
    start)
        do_start
    ;;
    stop)
        do_stop
    ;;
esac
exit 0
