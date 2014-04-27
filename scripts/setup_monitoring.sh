#!/bin/sh
##
## A script for a TP-Link TL-MR3020 device
## that configures monitoring tools for
## logging wifi traffic and sending it to a given host
##
## Author: <jensep@gmail.com>
##

if [ $# -ne 1 ] ; then
	echo "Usage: setup_monitoring.sh host-address"
fi

# Install necessary packages
opkg install libcap libpcap
# Install tcpdump on ram (-d for destination) since it's too big
# for main memory (!)
opkg -d ram install tcpdump

# Create necessary folders
mkdir /tmp/data

# Setup startup-script and a cron job to check wifi liveness
printf "/root/startup.sh\n\nexit 0\n" > /etc/rc.local
chmod +x /etc/rc.local
echo "*/1 * * * * /root/check_alive.sh" > /etc/crontabs/root

# Set permissions for scripts
chmod +x /root/capture.sh /root/check_alive.sh /root/postprocess.sh