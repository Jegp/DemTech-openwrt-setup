#!/bin/sh

# Create a counter to keep track of (possible) different running instances
# across boots
if [ ! -e /home/n ] ; then
	echo "0" > /home/n
fi

# Increment the counter
N=$(($(cat /home/n) + 1))
echo $N > /home/n

# Start tcpdump with flags:
# -i      The interface
# -B 100  Buffer size of the OS to limit consumption
# -w      Binary output file
# -C      Capture size before file-rotation (in kB)
# -n      Don't resolve addresses
# -e      Include link-level headers
# -q      Quiet means reduced output (not really sure what it does)
# -s      Package size (we don't care about the actual data)
# -z      A script to post-proccess the rotated files (from the w option)
#         - sends the file over the network and deletes it
/tmp/usr/sbin/tcpdump \
    -i wlan0 -B 100 -w "/tmp/data/${N}_dump" -C 1 -neq -s 0 \
    -z /home/postprocess & 

