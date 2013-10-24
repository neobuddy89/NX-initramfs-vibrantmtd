#!/system/xbin/busybox sh

BB=/system/xbin/busybox

$BB mount -t rootfs -o remount,rw rootfs;
$BB mount -o remount,rw /system;

# first mod the partitions then boot
$BB sh /sbin/ext/system_tune_on_init.sh;

# set sysrq to 2 = enable control of console logging level
echo "2" > /proc/sys/kernel/sysrq;

# enable kmem interface for everyone
echo "0" > /proc/sys/kernel/kptr_restrict;

(
	$BB sh /sbin/ext/run-init-scripts.sh;
)&

(
	# ROOTBOX fix notification_wallpaper
	if [ -e /data/data/com.aokp.romcontrol/files/notification_wallpaper.jpg ]; then
		chmod 777 /data/data/com.aokp.romcontrol/files/notification_wallpaper.jpg
	fi;

	while [ ! `cat /proc/loadavg | cut -c1-4` \< "3.50" ]; do
		echo "Waiting For CPU to cool down";
		sleep 10;
	done;

	sync;
	sysctl -w vm.drop_caches=3
	sync;
	sysctl -w vm.drop_caches=1
	sync;
)&

(
	$BB mount -o remount,rw rootfs;

	DM=`ls -d /sys/block/loop*`;
	for i in ${DM}; do
                        echo "0" > ${i}/queue/rotational;
                        echo "0" > ${i}/queue/iostats;
			echo "64" > ${i}/queue/nr_requests;
        done;



	mount -o remount,rw /system;
	mount -o remount,rw /;

	setprop persist.sys.scrollingcache 3
	setprop windowsmgr.max_events_per_sec 300
	setprop ro.max.fling_velocity 12000
	setprop ro.min.fling_velocity 8000

	echo "Done Booting" > /data/nx-boot-check;
	date >> /data/nx-boot-check;
)&
