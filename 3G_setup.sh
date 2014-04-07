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
opkg install kmod-usb2 libusb chat comgt luci-proto-3g

# USB modeswitch to set the 3G device to non-flash state
opkg install usb-modeswitch-data usb-modeswitch

# Dongle control packages
opkg install kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-wwan

##
## Setup 3G dongle
##

# Setup the dongle driver with the right info about the E353 device
sed -i '2iDefaultVendor= 0x12d1' /etc/usb_modeswitch.d/12d1\:1f01
sed -i '3iDefaultProduct=0x1f01' /etc/usb_modeswitch.d/12d1\:1f01

# Setup network information
sed -i '14i config interface \'wan\'' /etc/config/network
sed -i '15i \\\toption ifname ppp0' /etc/config/network
sed -i '16i \\\toption pincode $1' /etc/config/network
sed -i '17i \\\toption device /dev/ttyATH' /etc/config/network
sed -i '18i \\\toption apn internet' /etc/config/network
sed -i '19i \\\toption service umts' /etc/config/network
sed -i '20i \\\toption proto 3g' /etc/config/network

# Configure chat
sed -i 's/***1//g' /etc/chatscripts/3g.chat

##
## Setup monitoring tools
##

# Install tcpdump on ram (-d for destination) since it's too big
# for main memory (!)
opkg -d ram install tcpdump comgt

# Install the custom client package
opkg install /home/client.ipk

# Setup startup-script and a cron job to check wifi liveness
printf "/home/capture\n\nexit 0\n" > /etc/rc.local
chmod +x /etc/rc.local
echo "*/1 * * * * /home/check_alive" > /etc/crontabs/root

# Set permissions for scripts
chmod +x /home/capture /home/check_alive /home/postprocess
