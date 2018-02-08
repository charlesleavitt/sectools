#!/bin/bash
#################################################################
# CHECKING TO SEE IF INTERFACE IS PROVIDED
#################################################################
if [ -z ${1} ]
then
	echo "MESSAGE: Usage: `basename ${0}` [interface] [BSSID] [channel]"
	echo "MESSAGE: Example #`basename ${0}` wlan0 "
	exit 1
else
	INTERFACE="`echo "${1}" | cut -c 1-6`"
	echo "MESSAGE: Putting ${INTERFACE} in monitor mode"
fi
#################################################################
# GET INTERFACE MAC ADDRESS
#################################################################
MACADDRESS=`ifconfig ${INTERFACE} | grep ether | tr -s ' ' | cut -d ' ' -f3 | cut -c 1-17`
echo "MAC Addr: ${MACADDRESS}"
#################################################################
# PUT WIFI IN MONITOR MODE
#################################################################
#INTERFACE="`echo "wlan0"`"
echo $INTERFACE
airmon-ng check kill
airmon-ng start ${INTERFACE}

INTERFACE="`echo "${INTERFACE}mon"`"
echo "new interface: ${INTERFACE}" 
iwconfig ${INTERFACE} # mon0

# WAIT TO STOP AIRMON-NG
read -p "MESSAGE: Press enter to stop airmon-ng"

airmon-ng stop ${INTERFACE}
# RESTART SERVICES
/etc/init.d/networking restart
sleep 3
service network-manager restart
echo "Services Restarted - Have Nice Day"
exit 0
