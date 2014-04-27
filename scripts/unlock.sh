#!/bin/sh
##
## A script to unlock a 3G dongle at /dev/ttyUSB0
##
## Author: <jensep@gmail.com>

# Open device
cat /dev/ttyUSB2 &
PID=$!

# Ask the device for the IMEI
#IMEI=`echo -e "ATI\r" > /dev/ttyUSB2 | grep IMEI | cut -d f2`
#CODE=`python unlock.py $IMEI`
#echo -e 'AT^CARDLOCK="$CODE"\r' > /dev/ttyUSB2#!/bin/ash
