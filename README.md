
### power drain

* with WiFi on and no sleep ~1% in 30min => 100% in 2 days + 4 hours

```
[root@kindle root]# while :;do echo "$(date) => $( gasgauge-info -s)"; sleep 900; done
Tue Jan  2 18:34:35 UTC 2024 => 88%
...
Wed Jan  3 10:19:40 UTC 2024 => 58%
```

* without WiFi and sleep active, only short power on each 15min
