# Add the gateway to the host machine
route add default gw 192.168.0.2

# 
printf "search lan\nnameserver 8.8.8.8\n" > /etc/resolv.conf

opkg update
opkg install kmod-usb-storage \
     kmod-fs-vfat kmod-fs-ext4 \
     block-mount kmod-nls-cp437 kmod-nls-iso8859-1

opkg update
mkdir /home
mount /dev/sda1 /home
mkdir /home/opkg
mkdir /home/data

sed '4 i dest usb /home/opkg' /etc/opkg.conf > /tmp/opkg.conf
mv /tmp/opkg.conf /etc/opkg.conf

opkg update
opkg install libcap libpcap
opkg -d usb install tcpdump

printf "mount /dev/sda1 /home\n/home/capture\n\nexit 0\n" > /etc/rc.local
chmod +x /etc/rc.local
echo "*/1 * * * * /home/check_alive" > /etc/crontabs/root
