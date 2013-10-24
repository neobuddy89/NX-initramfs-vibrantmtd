#!/system/xbin/busybox sh

# stop ROM VM from booting!
stop;

# set busybox location
BB=/system/xbin/busybox

$BB chmod -R 777 /tmp/;
$BB chmod 6755 /sbin/ext/*;

mount -o remount,rw,nosuid,nodev /cache;
mount -o remount,rw,nosuid,nodev /data;
mount -o remount,rw /;

# cleaning
$BB rm -rf /cache/lost+found/* 2> /dev/null;
$BB rm -rf /data/lost+found/* 2> /dev/null;
$BB rm -rf /data/tombstones/* 2> /dev/null;
$BB rm -rf /data/anr/* 2> /dev/null;

# critical Permissions fix
$BB chown -R root:system /sys/devices/system/cpu/;
$BB chown -R system:system /data/anr;
$BB chown -R root:radio /data/property/;
$BB chmod -R 777 /tmp/;
$BB chmod -R 6755 /sbin/ext/;
$BB chmod -R 0777 /dev/cpuctl/;
$BB chmod -R 0777 /data/system/inputmethod/;
$BB chmod -R 0777 /sys/devices/system/cpu/;
$BB chmod -R 0777 /data/anr/;
$BB chmod 0744 /proc/cmdline;
$BB chmod -R 0770 /data/property/;
$BB chmod -R 0400 /data/tombstones;

# Setting swappiness to 0 which means to swap only if out of memory
echo "0" > /proc/sys/vm/swappiness;

# for on the fly changes we need to shutdown ZRAM first
swapoff /dev/block/zram0 >/dev/null 2>&1;
echo "1" > /sys/block/zram0/reset;
# setting size of each ZRAM swap drives
echo "52428800" > /sys/block/zram0/disksize;
# creating SWAPS from ZRAM drives
mkswap /dev/block/zram0 >/dev/null;
echo 1 > /sys/block/zram0/initstate;
# activating ZRAM swaps with the same priority to load balance ram swapping
chmod 755 /system/xbin/swapon;
swapon /dev/block/zram0 >/dev/null 2>&1;

# Setting swappiness to 0 which means to swap only if out of memory
echo "0" > /proc/sys/vm/swappiness;

# Start ROM VM boot!
start;

# start adb shell
start adbd;
