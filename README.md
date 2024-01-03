### Hardware
* Linux eInk 6"/15.2cm display Amazon Kindle 4th generation model D01100 ~30€ on ebay @2023
* switch on SSH access: https://wiki.mobileread.com/wiki/Kindle4NTHacking#Jailbreak

### step1: cronjob on headless a webserver
* fetch your google calendar using [gcalcli](https://github.com/insanum/gcalcli)
* build a HTML page with your next appointments using [phantomjs](https://phantomjs.org)
* convert HTML to grayscale image using [imagemagick](https://imagemagick.org)

### step2: cronjob on eInk
* download image from your webserver and refresh screen

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
* https://www.mobileread.com/forums/showthread.php?t=88004

### power drain
* with WiFi on and no sleep ~1% in 30min => 100% in 2 days + 4 hours

```
[root@kindle root]# while :;do echo "$(date) => $( gasgauge-info -s)"; sleep 900; done
Tue Jan  2 18:34:35 UTC 2024 => 88%
...
Wed Jan  3 10:19:40 UTC 2024 => 58%
```

* without WiFi and sleep active, only short power on each 15min
