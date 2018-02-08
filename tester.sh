#!/bin/bash
AP=`echo "SANDERS.b"`
echo "$AP"
MACADDRESS=`ifconfig wlan0 | grep ether | tr -s ' ' | cut -d ' ' -f3 | cut -c 1-17`
echo "$MACADDRESS"

APMAC=`grep $AP aps-01.csv | cut -d ' ' -f1 | cut -c '1-17'`
echo "AP MAC: $APMAC"
echo 'newline'
HOSTMAC=`grep $APMAC aps-01.csv | tail -1 | tr -s ' ' | cut -d ' ' -f1 | cut -c '1-17'`
echo "HOST MAC $HOSTMAC"
