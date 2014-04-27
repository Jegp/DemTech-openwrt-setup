# Add the gateway to the host machine
route add default gw 192.168.0.2

# Adds googles nameserver as address resolver
printf "search lan\nnameserver 8.8.8.8\n" > /etc/resolv.conf

# Create necessary folders
mkdir /home
mkdir /tmp/data

# Opdate package manager and install necessary packages
opkg update
opkg install libcap libpcap
# Install tcpdump on ram (-d for destination) since it's too big
# for main memory (!)
opkg -d ram install tcpdump 
# Install the custom client package
opkg install /home/client.ipk

# Setup startup-script and a cron job to check wifi liveness
printf "/home/capture\n\nexit 0\n" > /etc/rc.local
chmod +x /etc/rc.local
echo "*/1 * * * * /home/check_alive" > /etc/crontabs/root

# Set permissions for scripts
chmod +x /home/capture /home/check_alive /home/postprocess