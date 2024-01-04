#!/bin/sh
# shellcheck shell=dash

case "$1" in
	install)
		CRONTAB=/etc/crontab/root

		if grep "$0 cronjob" "$CRONTAB"; then
			echo "[OK] already installed in $CRONTAB"
		else
			grep "/dev/root / " /proc/mounts | grep -q 'ro,' && mntroot rw
			chmod +x "$0"
			printf '\n%s\n' "* * * * * $0 cronjob" >>"$CRONTAB" && mntroot ro
			echo "[OK] cronjob installed"
		fi

		exit 0
	;;
	cronjob) mkdir /var/eink-lock 2>/dev/null || exit 0 ;;
	*) echo "Usage: $0 <install|cronjob|help>" && exit 1
esac

URL="http://intercity-vpn.de/files/2024-01-03/upload/eink.png"
DST="/var/image.png"	# should be on a RAM-disk / tmpfs
INTERVAL=900		# in [seconds]

fixup_dns()
{
	test -s /etc/resolv.conf || echo "nameserver 8.8.8.8" >/etc/resolv.conf
}

REMEMBER_DEFGW="$( ip route list exact 0.0.0.0/0 )"
[ -z "$REMEMBER_DEFGW" ] && REMEMBER_DEFGW='default via 100.64.0.1 dev wlan0' && {
	# shellcheck disable=SC2086
	ip route add $REMEMBER_DEFGW
	fixup_dns
}

network_default_gateway()
{
	ip route list exact 0.0.0.0/0 | grep -q .
}

wifi_enable()
{
	# list all inter-process communication system flags: lipc-probe -a
	lipc-set-prop com.lab126.cmd wirelessEnable 1
	while ! wifi_isready; do sleep 1; done
}

wifi_disable()
{
	lipc-set-prop com.lab126.cmd wirelessEnable 0
}

wifi_isready()
{
	lipc-get-prop com.lab126.wifid cmState | grep -q CONNECTED && {
		network_default_gateway || {
			# shellcheck disable=SC2046
			kill -SIGUSR1 $( pidof udhcpc )		# force DHCP renew

			sleep 15
			# shellcheck disable=SC2086
			network_default_gateway || ip route add $REMEMBER_DEFGW		# fallback to old
			fixup_dns
		}
	}
}

sleep_for()
{
	lipc-set-prop -i com.lab126.powerd rtcWakeup "$1"
}

wait_for_suspend_ready()
{
	local i=0
	while test $i -lt 60; do {
		powerd_test -s | grep -q Ready && return 0
		sleep 1 && i=$(( i + 1 ))
	} done

	# Powerd state: Active
	# Remaining time in this state: 356.085518
	# defer_suspend:0
	# suspend_grace:0
	# prevent_screen_saver:0
	# drive_mode:unknown
	# Battery Level: 96%
	# Last batt event at: 96%
	# Charging: No
	# batt_full=0
	# Battery logging: On
}

battery_percent()
{
	# gasgauge-info -s
	lipc-get-prop com.lab126.powerd battLevel
}

display_imagefile()
{
	local file="$1"

	eips -c			# clear screen
	eips -g "$file"
}

power_connected()
{
	local bool_true=1
	lipc-get-prop -i com.lab126.powerd isCharging | grep -q "$bool_true"
}

download_image()
{
	percent="$( battery_percent )"
	rm -f "$DST"
	wget -O "$DST" "${URL}#${percent}"	# for debugging we send the powerstate during
}

toolbar_disable()
{
	/etc/init.d/framework stop
	# lipc-set-prop com.lab126.pillow disableEnablePillow disable
}

screensaver_disable()
{
	lipc-set-prop com.lab126.powerd preventScreenSaver 1
}

# toolbar_disable
screensaver_disable

while true; do {
	wifi_isready || wifi_enable

	HASH_OLD="$( test -f "$DST" && md5sum "$DST" )"
	download_image && {
		HASH_NEW="$( md5sum "$DST" )"
		test "$HASH_OLD" = "$HASH_NEW" || display_imagefile "$DST"
	}

	if power_connected; then
		sleep "$INTERVAL"
	else
		wifi_disable
		wait_for_suspend_ready
		sleep_for "$INTERVAL" sec
	fi
} done
