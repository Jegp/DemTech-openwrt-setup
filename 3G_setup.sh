#!/bin/ash
##
## Setup script for a TP-Link TL-MR3020 device
## with a Huawei E353Ws-2 3G dongle
##
## Note: We use the unstable Barrier Breaker to
## avoid a bug where USB devices suddenly disconnects
##
## Author: <jensep@gmail.com>
##

# Add the gateway to the host machine
route add default gw 192.168.0.2

# Adds googles nameserver as address resolver
printf "search lan\nnameserver 8.8.8.8\n" > /etc/resolv.conf

##
## Opdate package manager and install necessary packages
##
opkg update

## Packages on root device
# Libcap
opkg install libcap libpcap

# USB drivers and tools
opkg install kmod-usb2 libusb chat comgt

# USB modeswitch to set the 3G device to non-flash state
opkg install usb-modeswitch

# Dongle control packages
opkg install kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-wwan

##
## Setup 3G dongle
##

# Initialize the right drivers on detection
echo "usbserial vendor=0x12d1 product=0x1001" > /etc/modules.d/usb-serial

# Setup the dongle driver with the right info about the E353 device
sed -i '68i              ,"55534243ee0000006000000000000611063000000000000100000000000000"' /etc/usb-mode.json
sed -e "1349s/24/64/" /etc/usb-mode.json

# Setup network information
sed -i '14i config interface \'ppp0\'' /etc/config/network
sed -i '15i \\\toption ifname ppp0' /etc/config/network
sed -i '16i \\\toption pincode $1' /etc/config/network
sed -i '17i \\\toption device /dev/ttyUSB0' /etc/config/network
sed -i '18i \\\toption apn internet' /etc/config/network
sed -i '19i \\\toption service umts' /etc/config/network
sed -i '20i \\\toption proto 3g' /etc/config/network
sed -i '21i \\\toption Username Fullrate' /etc/config/network
sed -i '22i \\\toption Password Fullrate' /etc/config/network

# Configure chat
sed -i 's/***1//g' /etc/chatscripts/3g.chat

##
## Setup monitoring tools
## TODO
##

# Install tcpdump on ram (-d for destination) since it's too big
# for main memory (!)
#opkg -d ram install tcpdump comgt

# Install the custom client package
#opkg install /home/client.ipk

# Setup startup-script and a cron job to check wifi liveness
#printf "/home/capture\n\nexit 0\n" > /etc/rc.local
#chmod +x /etc/rc.local
#echo "*/1 * * * * /home/check_alive" > /etc/crontabs/root

# Set permissions for scripts
#chmod +x /home/capture /home/check_alive /home/postprocess
