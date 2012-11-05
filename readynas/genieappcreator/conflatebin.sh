#!/bin/bash

# Get the directory where the script is
# actually located
EXEC_BASE=`dirname ${0}`
EXEC_NAME=`basename ${0}`

# Allow for some sort of "debug mode"
# which allow for keeping the work dir
# after the build run
DEBUG_MODE=
if [ "${1}" == "-d" ]; then
    DEBUG_MODE=1
    shift 1
fi

SOURCEJAR="appproxy.jar"
BIN_FILE=${1}
DEV_PREFIX=${2}
PREVDIR=`pwd`

PROPERFORMAT="Proper format is: ${EXEC_NAME} [-d] <BIN FILE> <DEV PREFIX> [-v version] [-m <META_KEY0>:<META_VALUE0] ... [-m <META_KEY(n)>:<META_VALUE(n)>]"

#   create an array with the meta data arguments
VERSION=
META_DATA=()
NEXT_IS="normal"
for arg in "$@"; do
    if [ "${arg}" = "-m" ]; then
        NEXT_IS="meta"
    elif [ "${arg}" = "-v" ]; then
        NEXT_IS="version"
    else
        case "${NEXT_IS}" in
            "meta")
                META_DATA[${#META_DATA[@]}]="-m ${arg}"
                NEXT_IS="normal"
                ;;
            "version")
                VERSION=${arg}
                NEXT_IS="normal"
                ;;
        esac
    fi
done


#   test the paths
if [ ! -f ${SOURCEJAR} ]; then
    echo "\"${SOURCEJAR}\" doesn't exist! exiting ..."
    echo "    ${PROPERFORMAT}"
    exit 1
fi
if [ -z "${BIN_FILE}" ]; then
    echo "BIN FILE \"${BIN_FILE}\" doesn't exist! exiting ..."
    echo "    ${PROPERFORMAT}"
    exit 1
fi
if [ ! -f "${BIN_FILE}" ]; then
    echo "BIN FILE \"${BIN_FILE}\" doesn't exist! exiting ..."
    echo "    ${PROPERFORMAT}"
    exit 1
fi
if [ -z ${DEV_PREFIX} ]; then
    echo "\"DEV PREFIX\" is missing! exiting ..."
    echo "    ${PROPERFORMAT}"
    exit 1
fi


TEMP_TARFILE="temp.tar"
# Allow for parallel builds
WORKING_DIR=`mktemp -d /tmp/cflt_XXXXXXXX`
rm -rf ${WORKING_DIR}
mkdir ${WORKING_DIR}


wrap_script()
{
    DEST_PATH=$1
    SRC_PATH=$2
    
    echo "#!/bin/sh" > ${DEST_PATH}
    echo "" >> ${DEST_PATH}
    echo "if [ -f ${SRC_PATH} ]; then" >> ${DEST_PATH}
    echo "    bash ${SRC_PATH}" >> ${DEST_PATH}
    echo "    exit \$?" >> ${DEST_PATH}
    echo "fi" >> ${DEST_PATH}
    echo "exit 1" >> ${DEST_PATH}
    echo "" >> ${DEST_PATH}
    chmod +x ${DEST_PATH}
}

#   unpack the zip contents of the bin file
dd if=${BIN_FILE} of=${WORKING_DIR}/${TEMP_TARFILE} bs=16384 skip=1
if [ -f ${WORKING_DIR}/${TEMP_TARFILE} ]; then
    SUCCESS=0
    
    #   create an empty directory for conflation content
    CONFLATION_PATH=${WORKING_DIR}/conflation
    mkdir -p ${CONFLATION_PATH}/payload
    cp ${BIN_FILE} ${CONFLATION_PATH}/payload/.

    #   move to the temp directory
    cd ${WORKING_DIR}
    tar -xf ${TEMP_TARFILE}
    
    #   extract the conf file contents
    OIFS=${IFS}
    IFS='~'
    array=(`cat addons.conf |sed -e 's/\!\!/~/g' -e 's/\:\:/~/g'`)
    IFS=${OIFS}
    
    APPNAME=${array[0]}
    FRIENDLY_NAME=${array[1]}
    if [ ! ${VERSION} ]; then
        VERSION=`echo "${array[2]}" |sed 's/[-a-z]//g'`
    fi
    START_PATH=${array[3]}
    STOP_PATH=${array[4]}
    CATEGORY=${array[5]}
    CURRENT_URL=
    DETAIL_URL=
    ICON_URL=
    for line in ${array[@]}; do
        KEY=`echo ${line} | cut -d "=" -f1`
        VALUE=`echo ${line} | cut -d "=" -f3`
        case ${KEY} in
        "detail_url")
            DETAIL_URL="${VALUE}"
            ;;
        "icon_url")
            ICON_URL="${VALUE}"
            ;;
        "current_url")
            CURRENT_URL="${VALUE}"
            ;;
        esac
    done

    #   unpack the header information
    ARCH=
    MIN_RADIATOR_VERSION=
    SKIPREBOOT=
    RESTARTAPACHE=
    HEADER_FILE="__header.txt"
    dd if=${PREVDIR}/${BIN_FILE} of=${WORKING_DIR}/${HEADER_FILE} bs=16384 count=1
    if [ -f ${WORKING_DIR}/${HEADER_FILE} ]; then
        OIFS=${IFS}
        IFS='~'
        array=(`cat ${HEADER_FILE} |sed -e 's/\,/~/g' -e 's/\:\:/~/g'`)
        IFS=${OIFS}
        for line in ${array[@]}; do
            KEY=`echo ${line} | cut -d "=" -f1`
            VALUE=`echo ${line} | cut -d "=" -f2`
            case ${KEY} in
            "arch")
                ARCH="${VALUE}"
                ;;
            "min_raidiator_version")
                MIN_RADIATOR_VERSION="${VALUE}"
                ;;
            "skipreboot")
                SKIPREBOOT="${VALUE}"
                ;;
            "restartapache")
                RESTARTAPACHE="${VALUE}"
                ;;
            esac
        done
    fi

    echo ""
    echo "   APPNAME                : ${APPNAME}"
    echo "   VERSION                : ${VERSION}"
    echo "   MIN_RADIATOR_VERSION   : ${MIN_RADIATOR_VERSION}"
    echo "   ARCH                   : ${ARCH}"
    echo "   FRIENDLY_NAME          : ${FRIENDLY_NAME}"
    echo "   START_PATH             : ${START_PATH}"
    echo "   STOP_PATH              : ${STOP_PATH}"
    echo "   CATEGORY               : ${CATEGORY}"
    echo "   DETAIL_URL             : ${DETAIL_URL}"
    echo "   CURRENT_URL            : ${CURRENT_URL}"
    echo "   ICON_URL               : ${ICON_URL}"
    echo "   SKIPREBOOT             : ${SKIPREBOOT}"
    echo "   RESTARTAPACHE          : ${RESTARTAPACHE}"
    echo ""
    
    #   extrude and test the running path
    RUNNING_PATH=`echo ${START_PATH} |sed -e 's/start.sh/running.sh/'`
    
    EXEC_PATH=${CONFLATION_PATH}/exec
    mkdir -p ${EXEC_PATH}
    
    #   copy the start, stop and running scripts
    wrap_script ${EXEC_PATH}/start.sh ${START_PATH}
    wrap_script ${EXEC_PATH}/stop.sh ${STOP_PATH}
    wrap_script ${EXEC_PATH}/isrunning.sh ${RUNNING_PATH}
    
    #   extrapolate isinstalled.sh
    echo "#!/bin/sh" > ${EXEC_PATH}/isinstalled.sh
    echo "" >> ${EXEC_PATH}/isinstalled.sh
    echo "if [ -f ${START_PATH} ]; then" >> ${EXEC_PATH}/isinstalled.sh
    echo "    exit 0" >> ${EXEC_PATH}/isinstalled.sh
    echo "fi" >> ${EXEC_PATH}/isinstalled.sh
    echo "exit 1" >> ${EXEC_PATH}/isinstalled.sh
    echo "" >> ${EXEC_PATH}/isinstalled.sh
    chmod +x ${EXEC_PATH}/isinstalled.sh

    cp ${PREVDIR}/install.sh ${EXEC_PATH}/.
    wrap_script ${EXEC_PATH}/uninstall.sh /etc/frontview/addons/${APPNAME}.remove

    # determine the icon's path
    ICON_PATH=
    if [ ${ICON_URL} ]; then
        ICON_NAME=`echo ${ICON_URL} |awk -F"/" '{ print $NF }'`
        if [ -f files.tgz ]; then
            mkdir files
            cd files
            tar xfz ../files.tgz
            ICON_PATH=`find . -iname ${ICON_NAME}`
        fi
    fi
    
    SUCCESS=1

    cd ${PREVDIR}
    
    if [ ${SUCCESS} -ne 0 ]; then
        echo "     successfully unpacked!"
        APPNAME=`echo ${APPNAME} |tr '[A-Z]' '[a-z]'`
        rm -f ${DEV_PREFIX}_${APPNAME}.jar
        bash ${EXEC_BASE}/conflate.sh ${SOURCEJAR} ${APPNAME} ${DEV_PREFIX}_${APPNAME} ${VERSION} ${CONFLATION_PATH}/exec ${CONFLATION_PATH}/payload ${META_DATA[@]}
        
        #   copy the icon if it is present
        if [ ${ICON_PATH} ]; then
            echo "  ... extracted icon ${ICON_NAME} from ${ICON_PATH}"
            cp ${WORKING_DIR}/files/${ICON_PATH} .
        fi
        
        META_FILE=addon.properties
        rm -f ${META_FILE}
        echo "APPNAME=${APPNAME}" >> ${META_FILE}
        echo "VERSION=${VERSION}" >> ${META_FILE}
        echo "MIN_RADIATOR_VERSION=${MIN_RADIATOR_VERSION}" >> ${META_FILE}
        echo "ARCH=${ARCH}" >> ${META_FILE}
        echo "FRIENDLY_NAME=${FRIENDLY_NAME}" >> ${META_FILE}
        echo "START_PATH=${START_PATH}" >> ${META_FILE}
        echo "STOP_PATH=${STOP_PATH}" >> ${META_FILE}
        echo "CATEGORY=${CATEGORY}" >> ${META_FILE}
        echo "CURRENT_URL=${CURRENT_URL}" >> ${META_FILE}
        echo "DETAIL_URL=${DETAIL_URL}" >> ${META_FILE}
        echo "ICON_NAME=${ICON_NAME}" >> ${META_FILE}
        echo "SKIPREBOOT=${SKIPREBOOT}" >> ${META_FILE}
        echo "RESTARTAPACHE=${RESTARTAPACHE}" >> ${META_FILE}
    fi
else
    echo "unable to unpack the contents of \"${BIN_FILE}\"!"
fi
if [ -z "${DEBUG_MODE}" ]; then
    rm -rf ${WORKING_DIR}
fi
