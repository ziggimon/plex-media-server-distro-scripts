#!/bin/sh
if [ `ifconfig | grep -q bond0` ]
then
IP_ADDR=`ifconfig bond0 | grep "inet addr" | awk '{print $2}' | awk -F: '{print $2}'`
else
IP_ADDR=`ifconfig eth0 | grep "inet addr" | awk '{print $2}' | awk -F: '{print $2}'`
fi
echo Location: http://${IP_ADDR}:32400/manage
echo ""
exit 0
