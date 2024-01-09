#!/bin/sh
# shellcheck shell=dash
#
# e.g.: ssh-copy-id root@10.63.44.33
WEBSERVER_UPLOAD='root@10.63.44.33:/www/eink-image.png'
MAX_LINES=10

query()		# show even todays appointments using faketime:
{
  timeout 15 faketime -f '-1d' gcalcli --nocolor agenda "$( LC_ALL=C date )" --military --nostarted
}

command -v 'faketime' >/dev/null || {
	echo "[ERROR] please install 'faketime'"
	exit 1
}

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

NBS='&nbsp;'
TEMP="$( mktemp )" || exit 1
GCAL_PLAINTTEXT="$( mktemp )" || exit 1

if query >"$TEMP"; then
  tr -d '\r' <"$TEMP" >"$GCAL_PLAINTTEXT"
else
  rm -f "$TEMP"
  exit 1
fi

emit_html()
{
  echo "<!DOCTYPE html><html lang=en><head><title>gcalcli-html-export</title>"
  echo "<meta charset='UTF-8'>"
  echo "<style>"
  echo ".table th {"
  echo "  background-color: #fff;"
  echo "  font-size: 6pt;"
  echo "}"
  echo "</style>"
  echo "</head><body bgcolor=white>"
  echo "<table cellspacing=1 cellpadding=1 width=100% border=1 height=100%>"
  echo " <tr>"
  echo "  <th align=center width=1%>Day</th>"
  echo "  <th align=center width=1%>Time</th>"
  echo "  <th align=left width=98%>${NBS}${NBS}Mission</th>"
  echo " </tr>"

  CUTPATTERN=
  I=0
  J=0
  while IFS= read -r LINE; do {
    I=$(( I + 1 ))

    case "$LINE" in
      ''|*'Kalenderwoche'*20[0-9][0-9]|*Feiertag*)
        I=$(( I - 1 ))
      ;;
      "Fri "*|"Sat "*|"Sun "*|"Thu "*|"Tue "*|"Wed "*|"Mon "*)
        J=$(( J + 1 ))
        test $I -ge $MAX_LINES && test -z "$CUTPATTERN" && CUTPATTERN='please-cut-here'

        # shellcheck disable=SC2086
        MISSION="$( echo "$LINE" | cut -b20-999 )" && set -- $MISSION && MISSION=$*
        # shellcheck disable=SC2086
        TIME="$(    echo "$LINE" | cut -b13-17 )" && set -- $TIME && TIME=$* && TIME="${TIME:-${NBS}}"
        DAY="$(     echo "$LINE" | cut -b1-10 )"

        test "$( LC_ALL=C date '+%a %b %d' )" = "$DAY" && DAY="<b>$DAY</b>"

        echo " <tr><!-- startofentry $J | line: $I | $CUTPATTERN -->"
        echo "  <td nowrap><tt>$DAY</tt></td>"
        echo "  <td align=right valign=top nowrap><tt>$TIME</tt></td>"
        echo "  <td>${NBS}${NBS}$MISSION</td>"
        echo " </tr>"
      ;;
      *)
        # shellcheck disable=SC2086
        MISSION="$( echo "$LINE" | cut -b20-999 )" && set -- $MISSION && MISSION=$*
        # shellcheck disable=SC2086
        TIME="$(    echo "$LINE" | cut -b13-17 )" && set -- $TIME && TIME=$* && TIME="${TIME:-${NBS}}"
        DAY="$NBS"

        echo " <tr><!-- line: $I -->"
        echo "  <td nowrap>$DAY</td>"
        echo "  <td align=right valign=top nowrap><tt>$TIME</tt></td>"
        echo "  <td>${NBS}${NBS}$MISSION</td>"
        echo " </tr>"
      ;;
    esac
  } done <"$GCAL_PLAINTTEXT" >"$TEMP"

  if [ -n "$CUTPATTERN" ]; then
    sed -n '1,/please-cut-here/p' "$TEMP" | head -n -1
  else
    cat "$TEMP"
  fi

  echo "</table></body></html>"
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

rm -f "$TEMPFILE" "$TEMPFILE.html" "$TEMPFILE.png" "$IMAGE" "$GCAL_PLAINTTEXT" "$TEMP"
