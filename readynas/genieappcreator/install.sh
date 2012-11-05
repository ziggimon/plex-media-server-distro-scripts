#!/bin/sh

PAYLOAD_DIR=$2

install_bin() 
{
    BIN_FILE=$1
    
    RETVAL=1
    
    TEMP_TARFILE="temp.tar"
    WORKING_DIR=/tmp/install_tmp
    rm -rf ${WORKING_DIR}
    mkdir ${WORKING_DIR}
    
    #   unpack the bin file
    dd if=${BIN_FILE} of=${WORKING_DIR}/${TEMP_TARFILE} bs=16384 skip=1
    if [ -f ${WORKING_DIR}/${TEMP_TARFILE} ]; then
        #   move to the temp directory
        PREV_DIR=`pwd`
        cd ${WORKING_DIR}
        tar -xf ${TEMP_TARFILE}
        
        #   call the install script
        if [ -f ./install.sh ]; then
            echo "found install.sh in \"${BIN_FILE}\""
            bash ./install.sh
            RETVAL=$?
        else
            echo "no install.sh in \"${BIN_FILE}\""
        fi
        
        cd ${PREV_DIR}
    else
        echo "unable to unpack the bin file \"${BIN_FILE}\""
    fi
    
    #   clean up the temp directory
    if [ -d ${WORKING_DIR} ]; then
        rm -rf ${WORKING_DIR}
    fi
    
    return ${RETVAL}
}


#   check for the existence of the payload directory
if [ -d ${PAYLOAD_DIR} ]; then
    for file in ${PAYLOAD_DIR}/*.bin; do
        install_bin ${file}
        exit $?
    done
else
    echo "payload directory \"$PAYLOAD_DIR\" doesn't exist! exiting ..."
fi

exit 1