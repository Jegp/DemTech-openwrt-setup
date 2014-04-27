#!/bin/sh
##
## A script to check if the wifi interface is up.
## If not, we force a restart. The effect is dubious.
##
## Author: <jensep@gmail.com>

# Echo run
echo "$(/bin/date +'%H:%M:%S'): Running check_alive" >> /tmp/log

# Compare sizes
SIZE=`du /tmp/data/$(ls /root/data/ -t | cut -f1 | head -n 1) | cut -f1`
OLD_SIZE_FILE=/root/old_size
OLD_SIZE=`cat $OLD_SIZE_FILE`

# Match file sizes
if [ $SIZE -eq $OLD_SIZE ] ; then
	# This is bad, mkay
	echo "$(/bin/date +'%H:%M:%S'): Stagnation identified; Rebooting network in all possible ways.\n" >> /root/log
	PID=$(/usr/bin/pgrep tcpdump)
	/etc/init.d/network restart 1>>/root/log 2>>/root/log
	/sbin/wifi 1>>/root/log 2>>/root/log

	# Process remaining data
	/root/postprocess /tmp/data/*
	# Restart capture
	/root/capture
	kill -9 $PID
fi
echo $SIZE > $OLD_SIZE_FILE

