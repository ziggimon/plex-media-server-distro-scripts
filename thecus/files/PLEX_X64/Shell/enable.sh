#!/bin/sh
res='fail'
mod_name=$1
mod_enable=$2
opath=`pwd`

if [ $mod_enable = 'No' ];then
  cd /raid/data/module/cfg/
  /raid/data/module/cfg/module.rc/"$mod_name.rc" start
  if [ $? -eq 0 ];then
    res='pass'
  fi
elif [ $mod_enable = 'Yes' ];then
  cd /raid/data/module/cfg/
  /raid/data/module/cfg/module.rc/"$mod_name.rc" stop
  if [ $? -eq 0 ];then
    res='pass'
  fi
fi

cd $opath
echo $res
