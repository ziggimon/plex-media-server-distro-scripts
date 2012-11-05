#!/bin/bash

SOURCEJAR=${1}
BUNDLENAME=${2}
BUNDLESYMBOLICNAME=${3}
BUNDLEVERSION=${4}
EXECPATH=${5}
PAYLOADPATH=${6}

PROPERFORMAT="Proper format is: <SOURCEJAR> <BUNDLENAME> <BUNDLESYMBOLICNAME> <BUNDLEVERSION> <EXECPATH> <PAYLOADPATH (optional)> [-m <META_KEY0>:<META_VALUE0>] ... [-m <META_KEY(n)>:<META_VALUE(n)>]"

#   create an array with the meta data arguments
META_DATA=()
NEXT_IS="normal"
for arg in "$@"; do
    if [ "${arg}" = "-m" ]; then
        NEXT_IS="meta"
    else
        case "${NEXT_IS}" in
            "meta")
                META_DATA[${#META_DATA[@]}]=${arg}
                NEXT_IS="normal"
                ;;
        esac
    fi
done


#   test the arguments
if [ $# -lt 5 ]; then
    echo "Invalid arguments! exiting ..."
    echo "    ${PROPERFORMAT}"
    exit 1
fi

#   test the paths
if [ ! -f ${SOURCEJAR} ]; then
    echo " \"${SOURCEJAR}\" doesn't exist! exiting ..."
    echo "    ${PROPERFORMAT}"
    exit 1
fi
if [ ! -d ${EXECPATH} ]; then
    echo "EXECPATH \"${EXECPATH}\" doesn't exist! exiting ..."
    echo "    ${PROPERFORMAT}"
    exit 1
fi
STARTSCRIPT=${EXECPATH}/start.sh
if [ ! -f ${STARTSCRIPT} ]; then
    echo "\"${STARTSCRIPT}\" doesn't exist! exiting ..."
    echo "    ${PROPERFORMAT}"
    exit 1
fi
STOPSCRIPT=${EXECPATH}/stop.sh
if [ ! -f ${STOPSCRIPT} ]; then
    echo "\"${STOPSCRIPT}\" doesn't exist! exiting ..."
    echo "    ${PROPERFORMAT}"
    exit 1
fi
ISRUNNINGSCRIPT=${EXECPATH}/isrunning.sh
if [ ! -f ${ISRUNNINGSCRIPT} ]; then
    echo "\"${ISRUNNINGSCRIPT}\" doesn't exist! exiting ..."
    echo "    ${PROPERFORMAT}"
    exit 1
fi
INSTALLCRIPT=${EXECPATH}/install.sh
if [ ! -f ${INSTALLCRIPT} ]; then
    echo "\"${INSTALLCRIPT}\" doesn't exist! exiting ..."
    echo "    ${PROPERFORMAT}"
    exit 1
fi
UNINSTALLSCRIPT=${EXECPATH}/uninstall.sh
if [ ! -f ${UNINSTALLSCRIPT} ]; then
    echo "\"${UNINSTALLSCRIPT}\" doesn't exist! exiting ..."
    echo "    ${PROPERFORMAT}"
    exit 1
fi
ISINSTALLED=${EXECPATH}/isinstalled.sh
if [ ! -f ${ISINSTALLED} ]; then
    echo "\"${ISINSTALLED}\" doesn't exist! exiting ..."
    echo "    ${PROPERFORMAT}"
    exit 1
fi



echo ""
echo "   BUNDLENAME             : ${BUNDLENAME}"
echo "   BUNDLESYMBOLICNAME     : ${BUNDLESYMBOLICNAME}"
echo "   BUNDLEVERSION          : ${BUNDLEVERSION}"
echo "   EXECPATH               : ${EXECPATH}"
if [ ${PAYLOADPATH} ]; then
    echo "   PAYLOADPATH            : ${PAYLOADPATH}"
fi
echo ""
echo "Conflating ..."


TEMPDIR=/tmp/conflate-temp

if [ -d ${TEMPDIR} ]; then
    rm -rf ${TEMPDIR}
fi
mkdir ${TEMPDIR}

#   make a copy of appproxy.jar
echo "  copying the source jarfile ..."
cp ${SOURCEJAR} ${TEMPDIR}/appproxy.jar

echo "  copying the resources ..."
#   exec path
mkdir ${TEMPDIR}/exec
cp -R ${EXECPATH}/* ${TEMPDIR}/exec/.
#   payload path
if [ ${PAYLOADPATH} ]; then
    mkdir ${TEMPDIR}/payload
    cp -R ${PAYLOADPATH}/* ${TEMPDIR}/payload/.
fi


#   jump to the temp director
PREVDIR=${PWD}
cd ${TEMPDIR}

#           modify
echo "  updating the manifest ..."
MANIFESTUPDATE=manifest.tmp
#           copy the app specific, user provided, manifest info
echo "Bundle-Version: ${BUNDLEVERSION}" > ${MANIFESTUPDATE}
echo "Bundle-Name: ${BUNDLENAME}" >> ${MANIFESTUPDATE}
echo "Bundle-SymbolicName: ${BUNDLESYMBOLICNAME}" >> ${MANIFESTUPDATE}
#           copy the core manifest info
echo "Manifest-Version: 1.0" >> ${MANIFESTUPDATE}
echo "4hm-Core-Version: 3.2.27" >> ${MANIFESTUPDATE}
echo "Ant-Version: Apache Ant 1.8.2" >> ${MANIFESTUPDATE}
echo "Subversion-Revision: 17146" >> ${MANIFESTUPDATE}
echo "Bundle-Activator: com.netgear.appproxy.AppProxyService" >> ${MANIFESTUPDATE}
echo "Bundle-ManifestVersion: 2" >> ${MANIFESTUPDATE}
echo "Created-By: 1.6.0_33-b03-424-11M3720 (Apple Inc.)" >> ${MANIFESTUPDATE}
echo "Import-Package: com.fourhome.commons, org.osgi.framework;version="1.3.0", org.osgi.service.http, javax.servlet, javax.servlet.http" >> ${MANIFESTUPDATE}

#           copy user defined manifest information if there is any
for meta_entry in "${META_DATA[@]}"; do
    META_KEY=`echo ${meta_entry} | cut -d ":" -f1`
    META_VALUE=`echo ${meta_entry} | cut -d ":" -f2-`
    echo "${META_KEY}: ${META_VALUE}" >> ${MANIFESTUPDATE}
done


echo "  creating an updated jar file ..."
if [ ${PAYLOADPATH} ]; then
    jar cfM payload.jar payload
    jar umf ${MANIFESTUPDATE} appproxy.jar exec payload.jar
else
    jar umf ${MANIFESTUPDATE} appproxy.jar exec
fi

mv -f appproxy.jar ${PREVDIR}/${BUNDLESYMBOLICNAME}.jar

echo "  cleaning up ..."
cd ${PREVDIR}
rm -rf ${TEMPDIR}

echo "  ... generated file: \"${BUNDLESYMBOLICNAME}.jar\""
