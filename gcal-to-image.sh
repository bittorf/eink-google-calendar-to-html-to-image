#!/bin/sh
# shellcheck shell=dash
#
# e.g.: ssh-copy-id root@10.63.44.33
WEBSERVER_UPLOAD='root@10.63.44.33:/www/eink-image.png'

command -v 'phantomjs' >/dev/null || {
	URL="https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2"

	cat <<EOF
[ERROR] missing 'phantomjs' from e.g. $URL

# possible installation (copy/paste):
URL='$URL'
DST='/usr/local/bin/phantomjs'
TARLOCATION='phantomjs-2.1.1-linux-x86_64/bin/phantomjs'
sudo touch "\$DST"
sudo chmod +x "\$DST"
curl -L -o - "\$URL" | sudo tar -C /usr/local/bin -xvjf - "\$TARLOCATION"
sudo mv "/usr/local/bin/\$TARLOCATION" "\$DST"
EOF
	exit 1
}

query()
{
  gcalcli --nocolor agenda "$( date )" --military --nostarted
}

NBS='&nbsp;'
TEMP="$( mktemp )" || exit 1
query | tr -d '\r' >"$TEMP"

emit_html()
{
echo "<!DOCTYPE html><html lang=en><head><title>gcalcli-html-export</title>"
echo "<meta charset='UTF-8'></head><body bgcolor=white>"
echo "<table cellspacing=1 cellpadding=1 width=100% border=1 height=100%>"
echo "<tr><th align=center width=1%>Day</th><th align=center width=1%>Time</th><th align=left width=98%>${NBS}${NBS}Mission</th></tr>"

while IFS= read -r LINE; do {
  case "$LINE" in
    '')
    ;;
    "Fri "*|"Sat "*|"Sun "*|"Thu "*|"Tue "*|"Wed "*|"Mon "*)
      # shellcheck disable=SC2086
      MISSION="$( echo "$LINE" | cut -b20-999 )" && set -- $MISSION && MISSION=$*
      TIME="$(    echo "$LINE" | cut -b13-17 )"
      DAY="$(     echo "$LINE" | cut -b1-10 )"
      echo "<tr><td nowrap><tt>$DAY</tt></td><td align=right valign=top nowrap><tt>$TIME</tt></td><td>${NBS}${NBS}$MISSION<td></tr>"
    ;;
    *)
      # shellcheck disable=SC2086
      MISSION="$( echo "$LINE" | cut -b20-999 )" && set -- $MISSION && MISSION=$*
      TIME="$(    echo "$LINE" | cut -b13-17 )"
      DAY="$NBS"
      echo "<tr><td nowrap>$DAY</td><td align=right valign=top nowrap><tt>$TIME</tt></td><td>${NBS}${NBS}$MISSION<td></tr>"
    ;;
  esac
} done <"$TEMP"

echo "</table><body></html>"
rm "$TEMP"
}

html_screenshot()
{
	local url="$1"			# e.g. file:///path/to/foo.html OR http://..
	local output_image="$2"		# must have a valid extension, e.g. *.png
	local script

	script="$( mktemp -d )" || return 1
	script="$script/phantom.js"

	cat >"$script" <<EOF
var page = require('webpage').create();
page.open('$url', function() {
    setTimeout(function() {
        page.render('$output_image');
        phantom.exit();
    }, 200);
});
EOF

	phantomjs --script-language=javascript "$script" || return 1
	rm -fR "$script"

	echo "$output_image"
}

TEMPFILE="$( mktemp )" || exit 1
emit_html >"$TEMPFILE.html"

IMAGE="$( html_screenshot "file://$TEMPFILE.html" plan.png )" && \
convert "$IMAGE" -type GrayScale -depth 8 -colors 256 -resize '800x600!' -rotate 90 "$TEMPFILE.png"
scp -O "$TEMPFILE.png" "$WEBSERVER_UPLOAD"

rm -f "$TEMPFILE" "$TEMPFILE.html" "$TEMPFILE.png" "$IMAGE"
