### Hardware
* Linux eInk 6"/15.2cm display Amazon Kindle 4th generation model D01100 ~30€ on ebay @2023
* switch on SSH access: https://wiki.mobileread.com/wiki/Kindle4NTHacking#Jailbreak

## setup

![Amazon Kindle 4th generation](https://github.com/bittorf/eink-google-calendar-to-html-to-image/blob/main/eink-calendar-example.jpg?raw=true)

### step1: cronjob on your (headless) webserver
the script ```gcal-to-image.sh``` does this:
* fetch a google calendar using [gcalcli](https://github.com/insanum/gcalcli)
* build HTML page with your next appointments
* convert HTML to an image using [phantomjs](https://phantomjs.org)
* rotate and convert it to grayscale image using [imagemagick](https://imagemagick.org)
* upload to a webserver, so that your eink-device can process it
```
user@box:~$ crontab -l | grep gcal-to-image
*/15 * * * * ~/gcal-to-image.sh >/dev/null
```

### step2: cronjob on eInk
* download image from your webserver and refresh screen with it
* install a cronjob:
```
/bin/eink-update-image.sh install
```

### similar projects:
* https://www.stavros.io/posts/making-the-timeframe/
* https://rahulrav.com/blog/e_ink_dashboard.html
* https://github.com/speedyg0nz/MagInkCal
* https://recalendar.me/
* https://mpetroff.net/2012/09/kindle-weather-display/
* https://news.ycombinator.com/item?id=11894613
* http://blog.bubux.de/amazon-kindle-als-statusdisplay-update/
* https://purisa.me/blog/eink-bird-clock/
* https://github.com/fread-ink/fread-ink and http://fread.ink/
* https://wiki.postmarketos.org/wiki/Amazon_Kindle_4_(amazon-yoshi)
* https://wiki.mobileread.com/wiki/Kindle_Screen_Saver_Hack_for_all_2.x,_3.x_%26_4.x_Kindles
* https://wiki.mobileread.com/wiki/Kindle4NTHacking#Jailbreak
* https://wiki.mobileread.com/wiki/Lipc
* https://www.mobileread.com/forums/showthread.php?t=88004
* https://www.mobileread.com/forums/showthread.php?t=221497
* https://github.com/dpavlin/k3libre
* https://github.com/dpavlin/k3libre/blob/master/kindle-display.sh
* https://shop.invisible-computers.com/
* https://github.com/schuhumi/alpine_kindle
* https://github.com/koreader/koreader/blob/master/platform/kindle/koreader.sh
* https://www.sixfoisneuf.fr/posts/kindle-hacking-deeper-dive-internals/
* https://en.wikipedia.org/wiki/Nook_Simple_Touch
* https://news.ycombinator.com/item?id=38928277
* https://en.wikipedia.org/wiki/Comparison_of_e-readers

### ToDo
* fallback to errorpage, if image-download fails
* make HTML more w3c validator safe (CSS)
* keep font aspect ratio (e.g. always output 12? lines)
* document special stuff (e.g. upload scp-command, download URL)
* make sleepmode and RTC-wakeup working: https://www.mobileread.com/forums/showthread.php?p=4246644
* measure power drain in sleepmode
* calc estimated time till 20% power (start loading then) or just charge monthly?
* try on kindle DX with 9.7"

### power drain
* Amazon MC-265360 - Li-Polymer 750mAh @3.7 Volt = 2.78 Wh
* with WiFi on and no sleep ~1% in 30min => 100% in 2 days + 4 hours

```
[root@kindle root]# while :;do echo "$(date) => $( gasgauge-info -s)"; sleep 900; done
Tue Jan  2 18:34:35 UTC 2024 => 88%
...
Wed Jan  3 10:19:40 UTC 2024 => 58%
```

* without WiFi and sleep active, only short power on each 15min

### charging
* needs around 76 sec for each percent (~90min from 20% to 80%)
```
[root@kindle root]# while :;do echo "$(date) => $( gasgauge-info -s)"; sleep 60; done
Fri Jan  5 09:00:08 UTC 2024|4%
...
Fri Jan  5 10:44:16 UTC 2024|86%
```

### kernel inside
```
[root@kindle root]# cat /proc/cpuinfo
Processor	: ARMv7 Processor rev 5 (v7l)
BogoMIPS	: 159.90
Features	: swp half thumb fastmult vfp edsp neon vfpv3
CPU implementer	: 0x41
CPU architecture: 7
CPU variant	: 0x2
CPU part	: 0xc08
CPU revision	: 5

Hardware	: Amazon.com MX50 YOSHI Board
Revision	: 50011
Serial		: "B00E151014961A67"
BoardId		: "0031501114940HQR"

[root@kindle root]# dmesg
Linux version 2.6.31-rt11-lab126 (jenkins-official@lucid-build02) (gcc version 4.5.3 20110406 (prerelease) (Linaro GCC 4.5-2011.04-0) ) #5 Sat Jan 12 20:39:09 PST 2013
CPU: ARMv7 Processor [412fc085] revision 5 (ARMv7), cr=10c53c7f
CPU: VIPT nonaliasing data cache, VIPT nonaliasing instruction cache
Machine: Amazon.com MX50 YOSHI Board
Board ID and Serial Number driver for Lab126 boards version 1.0
MX50 Board id - 0031501114940HQR
Memory policy: ECC disabled, Data cache writeback
On node 0 totalpages: 65536
free_area_init_node: node 0, pgdat c0491c3c, node_mem_map c04bd000
  DMA zone: 192 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 24384 pages, LIFO batch:3
  Normal zone: 320 pages used for memmap
  Normal zone: 40640 pages, LIFO batch:7
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 65024
Kernel command line: consoleblank=0 rootwait ro ip=off root=/dev/mmcblk0p1 debug eink=fslepdc video=mxcepdcfb:E60,bpp=8 console=ttymxc0,115200
PID hash table entries: 1024 (order: 10, 4096 bytes)
Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
Memory: 256MB = 256MB total
Memory: 254860KB available (3380K code, 363K data, 1068K init, 0K highmem)
NR_IRQS:368
MXC IRQ initialized
cko2_set_rate, new divider=5
MXC_Early serial console at MMIO 0x53fbc000 (options '115200')
console [ttymxc0] enabled
Console: colour dummy device 80x30
Calibrating delay loop... 799.53 BogoMIPS (lpj=3997696)
Mount-cache hash table entries: 512
CPU: Testing write buffer coherency: ok
regulator: core version 0.5
NET: Registered protocol family 16
i.MX IRAM pool: 128 KB@0xd0840000
CPU is i.MX50 Revision 1.1
MXC GPIO hardware
Using SDMA I.API
MXC DMA API initialized
bio: create slab <bio-0> at 0
mxc_spi mxc_spi.0: can't setup spi1.0, status -22
CSPI: mxc_spi-0 probed
mxc_spi mxc_spi.1: chipselect 0 already in use
mxc_spi mxc_spi.1: chipselect 0 already in use
CSPI: mxc_spi-1 probed
mxc_spi mxc_spi.2: chipselect 0 already in use
CSPI: mxc_spi-2 probed
MXC I2C driver
MXC I2C driver
PMIC Light driver loading...
mc13892 Rev 2.1 FinVer 2 detected
Initializing regulators for mx50 yoshi.
regulator: SW1: 600 <--> 1375 mV 
regulator: SW2: 900 <--> 1850 mV 
regulator: SW3: 900 <--> 1850 mV 
regulator: SW4: 1100 <--> 1850 mV 
regulator: SWBST: 0 mV 
regulator: VIOHI: 0 mV 
regulator: VPLL: 1050 <--> 1800 mV 
regulator: VDIG: 1200 mV 
regulator: VSD: 1800 <--> 3150 mV 
regulator: VUSB2: 2400 <--> 2775 mV 
regulator: VVIDEO: 2775 mV 
regulator: VAUDIO: 2300 <--> 3000 mV 
regulator: VCAM: 2500 <--> 3000 mV fast normal 
regulator: VGEN1: 3000 mV 
regulator: VGEN2: 1200 <--> 3150 mV 
regulator: VGEN3: 1800 mV 
regulator: VUSB: 0 mV 
regulator: GPO1: 0 mV 
regulator: GPO2: 0 mV 
regulator: GPO3: 0 mV 
regulator: GPO4: 0 mV 
PMIC ADC start probe
PMIC Light successfully loaded
Device spi3.0 probed
NET: Registered protocol family 2
IP route cache hash table entries: 2048 (order: 1, 8192 bytes)
TCP established hash table entries: 8192 (order: 4, 65536 bytes)
TCP bind hash table entries: 8192 (order: 3, 32768 bytes)
TCP: Hash tables configured (established 8192 bind 8192)
TCP reno registered
NET: Registered protocol family 1
LPMode driver module loaded
Static Power Management for Freescale i.MX5
PM driver module loaded
sdram autogating driver module loaded
Bus freq driver module loaded
Initializing MX50 Yoshi Accessory Port
mxc_dvfs_core_probe
DVFS driver module loaded
i.MXC CPU frequency driver
msgmni has been set to 498
alg: No test for stdrng (krng)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
regulator: DISPLAY: 0 mV 
regulator: GVDD: 20000 mV 
regulator: GVEE: -22000 mV 
regulator: VCOM: 0 <--> 2749 mV 
regulator: VNEG: -15000 mV 
regulator: VPOS: 15000 mV 
regulator: TMST: 0 mV 
papyrus 1-0048: PMIC PAPYRUS for eInk display
Amazon MX35 Yoshi Power Button Driver
Serial: MXC Internal UART driver
mxcintuart.0: ttymxc0 at MMIO 0x53fbc000 (irq = 31) is a Freescale MXC
console handover: boot [ttymxc0] -> real [ttymxc0]
loop: module loaded
mxc_rtc mxc_rtc.0: rtc core: registered mxc_rtc as rtc0
Probing mxc_rtc done
mc13892 rtc probe start
pmic_rtc pmic_rtc.1: rtc core: registered pmic_rtc as rtc1
mc13892 rtc probe succeed
i2c /dev entries driver
MXC WatchDog Driver 2.0
MXC Watchdog # 0 Timer: initial timeout 127 sec
MXC Watchdog: Started 10000 millisecond watchdog refresh
PMIC Character device: successfully loaded
pmic_battery: probe of pmic_battery.1 failed with error -1
sdhci: Secure Digital Host Controller Interface driver
sdhci: Copyright(c) Pierre Ossman
mxsdhci: MXC Secure Digital Host Controller Interface driver
mxsdhci: MXC SDHCI Controller Driver. 
mmc0: SDHCI detect irq 273 irq 2 INTERNAL DMA
mxsdhci: MXC SDHCI Controller Driver. 
mmc1: SDHCI detect irq 0 irq 3 INTERNAL DMA
Registered led device: pmic_ledsr
Registered led device: pmic_ledsg
Registered led device: pmic_ledsb
nf_conntrack version 0.5.0 (4096 buckets, 16384 max)
ip_tables: (C) 2000-2006 Netfilter Core Team
TCP cubic registered
NET: Registered protocol family 17
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
kernel: I perf:kernel:kernel_loaded=0.79 seconds:
VFP support v0.3: implementor 41 architecture 3 part 30 variant c rev 2
regulator_init_complete: disabling TMST
regulator_init_complete: disabling VCOM
regulator_init_complete: disabling GPO4
regulator_init_complete: disabling GPO3
regulator_init_complete: disabling GPO2
regulator_init_complete: disabling GPO1
regulator_init_complete: disabling VGEN3
regulator_init_complete: disabling VGEN1
regulator_init_complete: disabling VCAM
regulator_init_complete: disabling VAUDIO
regulator_init_complete: disabling VVIDEO
regulator_init_complete: disabling VSD
regulator_init_complete: disabling SWBST
mxc_rtc mxc_rtc.0: setting system clock to 2024-01-04 16:51:28 UTC (1704387088)
Freeing init memory: 1068K
mmc0: queuing CIS tuple 0x01 length 3
mmc0: queuing CIS tuple 0x1a length 5
mmc0: queuing CIS tuple 0x1b length 8
mmc0: queuing CIS tuple 0x14 length 0
mmc0: queuing CIS tuple 0x80 length 1
mmc0: queuing CIS tuple 0x81 length 1
mmc0: queuing CIS tuple 0x82 length 1
mmc0: new high speed SDIO card at address 0001
emmc: I def:mmcpartinfo:vendor=sandisk, ddr=1, host=mmc1:
mmc1: new high speed MMC card at address 0001
mmcblk0: mmc1:0001 SEM02G 1.82 GiB 
 mmcblk0: p1 p2 p3 p4
mxc_epdc_fb_init_hw: 06_05_006a_3c_157521_02_37_000001c8_85_01.wbf
eink_fb: I EINKFB_PROBE:def:fb0 using 1416K of RAM for framebuffer
input: tequila-keypad as /devices/platform/tequila-keypad/input/input0
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with writeback data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on mmcblk0p3, internal journal
EXT3-fs: recovery complete.
EXT3-fs: mounted filesystem with writeback data mode.
kernel: I perf:usb:usb_gadget_loaded=6.53 seconds:
g_file_storage gadget: File-backed Storage Gadget, version: 7 August 2007
g_file_storage gadget: Number of LUNs=1
fuse init (API version 7.12)
input: tequila-keypad as /devices/platform/tequila-keypad/input/input1
mxc_keyb: I def:drv::Keypad driver loaded
input: fiveway as /devices/virtual/input/input2
volume: I def:probe0::Starting...
volume: I def:probe_done::GPIOs and IRQs have been set up
input: volume as /devices/virtual/input/input3
volume: I def:drv::Volume key driver loaded
Loading Atheros ar6003 driver
SDIO: Enabling device mmc0:0001:1...
SDIO: Enabled device mmc0:0001:1
kernel: I perf:wifi:wifi_driver_loaded=11.43 seconds:
ar6003 Driver returning from ar6000_init_module
ar6k_wlan mmc0:0001:1: firmware: requesting /opt/ar6k/target/AR6003/hw2.1.1/bin/active_calibration
MAC from kernel xx:xx:xx:xx:B3:3C
ar6k_wlan mmc0:0001:1: firmware: requesting /opt/ar6k/target/AR6003/hw2.1.1/bin/otp.bin
ar6k_wlan mmc0:0001:1: firmware: requesting /opt/ar6k/target/AR6003/hw2.1.1/bin/athwlan.bin
ar6k_wlan mmc0:0001:1: firmware: requesting /opt/ar6k/target/AR6003/hw2.1.1/bin/data.patch.hw3_0.bin
wmi_control_rx() : Unknown id 0x101e
ar6003 driver: Completed loading the module ar6000_avail_ev
unregistered gadget driver 'g_file_storage'
kernel: I perf:usb:usb_gadget_loaded=16.34 seconds:
usb0: MAC ee:19:00:00:00:00
usb0: HOST MAC ee:49:00:00:00:00
g_ether gadget: Ethernet Gadget, version: Memorial Day 2008
g_ether gadget: g_ether ready
mxc_rtc: saved=0x9b755 boot=0x9b792
boot: I def:rbt:reset=user_reboot,version=181303:
arcotg_udc: I pmic:chargerWall:mV=3436:
arcotg_udc: I pmic:bponLobat:mV=3436:
arcotg_udc: I pmic:bponHi:mV=3817
arcotg_udc: I pmic:faulti:sense_0=0x200:battery dies/charger times out.
```
