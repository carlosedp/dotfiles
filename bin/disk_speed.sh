DISK=$1 # <===ADJUST THIS===
sync
echo 3 > /proc/sys/vm/drop_caches
blockdev --flushbufs $DISK
hdparm -Tt $DISK
