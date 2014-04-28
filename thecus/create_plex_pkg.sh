#!/bin/sh

if [ $PLEX_CONFIG == ubuntu-i686 -o $PLEX_CONFIG == ubuntu-x86_64 -o $PLEX_CONFIG == synology-ppc ]; then
    echo "build Thecus Module"
    PWD_PATH="`pwd`"
    TARGET_FOLDER=Plex
    TMP_FOLDER=thecus_temp
    rm -rf $TMP_FOLDER
    mkdir $TMP_FOLDER
    if [ $PLEX_CONFIG == ubuntu-i686 ]; then
      ARCH=i386
      PLEX_SYS_PATH="${TARGET_FOLDER}/sys_${ARCH}"
    elif [ $PLEX_CONFIG == ubuntu-x86_64 ]; then
      ARCH=x64
      PLEX_SYS_PATH="${TARGET_FOLDER}/System"
    elif [ $PLEX_CONFIG == synology-ppc ]; then
      ARCH=ppc
      PLEX_SYS_PATH="${TARGET_FOLDER}/sys_${ARCH}"
    fi
    MODULE_NAME="Plex_${PLEX_VERSION}_${ARCH}"

    # Building x64 module
    if [ $PLEX_CONFIG == ubuntu-x86_64 ]; then
      mkdir thecus_temp/${TARGET_FOLDER}
      cp -r files/PLEX_X64/* thecus_temp/${TARGET_FOLDER}
      sed -i "s/<%module_version%>/${PLEX_VERSION}/g" ${TMP_FOLDER}/${TARGET_FOLDER}/Configure/install.rdf
      cp -rfd ${PLEX_SRCDIR}/* ${TMP_FOLDER}/${PLEX_SYS_PATH}
      mv "${TMP_FOLDER}/${PLEX_SYS_PATH}/Plex DLNA Server" "${TMP_FOLDER}/${PLEX_SYS_PATH}/Plex_DLNA_Server"
      mv "${TMP_FOLDER}/${PLEX_SYS_PATH}/Plex Media Scanner" "${TMP_FOLDER}/${PLEX_SYS_PATH}/Plex_Media_Scanner"
      mv "${TMP_FOLDER}/${PLEX_SYS_PATH}/Plex Media Server" "${TMP_FOLDER}/${PLEX_SYS_PATH}/Plex_Media_Server"
      cd ${TMP_FOLDER}

      # Package it
      tar zcf ${MODULE_NAME}.tar.gz ./${TARGET_FOLDER} --exclude=".svn*"
      des -k AppModule -E ${MODULE_NAME}.tar.gz ${MODULE_NAME}.app
      md5sum ${MODULE_NAME}.app >  ${MODULE_NAME}.app.md5
      cp -f ${MODULE_NAME}.app ${MODULE_NAME}.app.md5 "${PLEX_OUTDIR}"
      cd ${PWD_PATH}
      rm -rf $TMP_FOLDER
    fi

   # Building i686/PPC RPM package
   if [ $PLEX_CONFIG == ubuntu-i686 -o $PLEX_CONFIG == synology-ppc ]; then
     mkdir -p ${TMP_FOLDER}/${TARGET_FOLDER}
     cp -R files/PLEX_RPM/Plex/src/*  ${TMP_FOLDER}/${TARGET_FOLDER}/.
     cp -R files/PLEX_RPM/Plex-spec/Plex.spec ${TMP_FOLDER}/.
     cp -R files/PLEX_RPM/REPO ${TMP_FOLDER}/.
     mkdir -p ${TMP_FOLDER}/${TARGET_FOLDER}/opt/Plex/sys
     cp -rfd ${PLEX_SRCDIR}/* "${TMP_FOLDER}/${TARGET_FOLDER}/opt/Plex/sys/."
     mv "${TMP_FOLDER}/${TARGET_FOLDER}/opt/Plex/sys/Plex DLNA Server" "${TMP_FOLDER}/${TARGET_FOLDER}/opt/Plex/sys/Plex_DLNA_Server"
     mv "${TMP_FOLDER}/${TARGET_FOLDER}/opt/Plex/sys/Plex Media Scanner" "${TMP_FOLDER}/${TARGET_FOLDER}/opt/Plex/sys/Plex_Media_Scanner"
     mv "${TMP_FOLDER}/${TARGET_FOLDER}/opt/Plex/sys/Plex Media Server" "${TMP_FOLDER}/${TARGET_FOLDER}/opt/Plex/sys/Plex_Media_Server"
     cd ${TMP_FOLDER}/${TARGET_FOLDER}/opt/Plex
     tar zcf sys.tar.gz ./sys
     rm -rf ./sys
     cd "${PWD_PATH}/${TMP_FOLDER}"

   # Package it
    VERSION=`echo ${PLEX_VERSION}| cut -d"-" -f1`
    GIT_VERSION=`echo ${PLEX_VERSION} | cut -d"-" -f2`
    sed -i "s/<%module_version%>/${VERSION}/g" Plex.spec
    sed -i "s/<%git_version%>/${GIT_VERSION}/g" Plex.spec
    sed -i "s/<%module_arch%>/${ARCH}/g" Plex.spec
    cd ${TARGET_FOLDER}
    rpmbuild -bb --buildroot=${PWD_PATH}/${TMP_FOLDER}/${TARGET_FOLDER} --target ${ARCH} ../Plex.spec

    cd ${PWD_PATH}/${TMP_FOLDER}
    cp Plex-${VERSION}-${GIT_VERSION}.${ARCH}.rpm REPO
    echo "Plex" > REPO/GroupName
    createrepo -g group.xml REPO/
    cd REPO
    tar zcf Plex.tar.gz ./*
    des -k AppModule -E Plex.tar.gz ${MODULE_NAME}.app
    md5sum ${MODULE_NAME}.app > ${MODULE_NAME}.app.md5
    cp -f ${MODULE_NAME}.app ${MODULE_NAME}.app.md5 "${PLEX_OUTDIR}"

    cd ${PWD_PATH}
    rm -rf ${TMP_FOLDER}
    fi


fi
