# Echo run
echo "$(/bin/date +'%H:%M:%S'): Running check_alive" >> /home/log

# Compare sizez
SIZE=`du /tmp/data/$(ls /home/data/ -t | cut -f1 | head -n 1) | cut -f1`
OLD_SIZE_FILE=/home/old_size
OLD_SIZE=`cat $OLD_SIZE_FILE`

# Match file sizes
if [ $SIZE -eq $OLD_SIZE ] ; then
	# This is bad, mkay
	echo "$(/bin/date +'%H:%M:%S'): Stagnation identified; Rebooting network in all possible ways.\n" >> /home/log
	PID=$(/usr/bin/pgrep tcpdump)
	/etc/init.d/network restart 1>>/home/log 2>>/home/log
	/sbin/wifi 1>>/home/log 2>>/home/log

        # Process remaining data
        /home/postprocess /tmp/data/*
        # Restart capture
	/home/capture
	kill -9 $PID
fi
echo $SIZE > $OLD_SIZE_FILE

