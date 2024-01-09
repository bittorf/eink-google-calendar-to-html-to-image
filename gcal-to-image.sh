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
GCAL_PLAINTEXT="$( mktemp )" || exit 1
GCAL_PLAINTEXT_OLD=/tmp/.cache_gcalcli

if query >"$TEMP"; then
  tr -d '\r' <"$TEMP" >"$GCAL_PLAINTEXT"
  cp "$GCAL_PLAINTEXT" "$GCAL_PLAINTEXT_OLD"
  ERROR=
else
  RC=$?
  cp "$GCAL_PLAINTEXT_OLD" "$GCAL_PLAINTEXT"

  if grep -q "Enter verification code:" "$TEMP"; then
    ERROR='ERROR: gcalcli needs re-auth!'
  else
    ERROR="ERROR: gcalcli RC:$RC"		# TODO: "Low battery 8%"?
  fi
fi

ribbon_css()
{
	cat <<EOF
/*!
 * "Fork me on chaos.expert" CSS ribbon v0.0.1 | MIT License
 * https://chaos.expert/chaos-expert/fork-ribbon
*/

.chaos-expert-fork-ribbon {
  width: 12.1em;
  height: 12.1em;
  position: absolute;
  overflow: hidden;
  top: 0;
  right: 0;
  z-index: 9999;
  pointer-events: none;
  font-size: 11.5px;
  text-decoration: none;
  text-indent: -999999px;
  text-align: center;
}

.chaos-expert-fork-ribbon.fixed {
  position: fixed;
}

.chaos-expert-fork-ribbon:before, .chaos-expert-fork-ribbon:after {
  /* The right and left classes determine the side we attach our banner to */
  position: absolute;
  display: block;
  width: 16.78em;
  height: 1.54em;
  
  top: 3.73em;
  right: -3.73em;
  
  -webkit-box-sizing: content-box;
  -moz-box-sizing: content-box;
  box-sizing: content-box;

  -webkit-transform: rotate(45deg);
  -moz-transform: rotate(45deg);
  -ms-transform: rotate(45deg);
  -o-transform: rotate(45deg);
  transform: rotate(45deg);
}

.chaos-expert-fork-ribbon:before {
  content: "";

  /* Add a bit of padding to give some substance outside the "stitching" */
  padding: .38em 0;

  /* Set the base colour */
  background-color: #e802c9;

  /* Set a gradient: transparent black at the top to almost-transparent black at the bottom */
  background-image: -webkit-gradient(linear, left top, left bottom, from(rgba(0, 0, 0, 0)), to(rgba(0, 0, 0, 0.15)));
  background-image: -webkit-linear-gradient(top, rgba(0, 0, 0, 0), rgba(0, 0, 0, 0.15));
  background-image: -moz-linear-gradient(top, rgba(0, 0, 0, 0), rgba(0, 0, 0, 0.15));
  background-image: -ms-linear-gradient(top, rgba(0, 0, 0, 0), rgba(0, 0, 0, 0.15));
  background-image: -o-linear-gradient(top, rgba(0, 0, 0, 0), rgba(0, 0, 0, 0.15));
  background-image: linear-gradient(to bottom, rgba(0, 0, 0, 0), rgba(0, 0, 0, 0.15));

  /* Add a drop shadow */
  -webkit-box-shadow: 0 .15em .23em 0 rgba(0, 0, 0, 0.5);
  -moz-box-shadow: 0 .15em .23em 0 rgba(0, 0, 0, 0.5);
  box-shadow: 0 .15em .23em 0 rgba(0, 0, 0, 0.5);

  pointer-events: auto;
}

.chaos-expert-fork-ribbon:after {
  /* Set the text from the title attribute */
  content: attr(title);

  /* Set the text properties */
  color: #fff;
  font: 700 1em "Ubuntu", "Droid Sans", "Helvetica Neue", Arial, sans-serif;
  line-height: 1.54em;
  text-decoration: none;
  /*text-shadow: 0 -.08em rgba(0, 0, 0, 0.5);*/
  text-align: center;
  text-indent: 0;

  /* Set the layout properties */
  padding: .15em 0;
  margin: .15em 0;

  /* Add "stitching" effect */
  border-width: .08em 0;
  border-style: dashed;
  border-color: #fff;
  border-color: rgba(255, 255, 255, 0.75);
}

.chaos-expert-fork-ribbon.red:before{
  background-color: #990000;
}

.chaos-expert-fork-ribbon.green:before{
  background-color: #009900;
}

.chaos-expert-fork-ribbon.blue:before{
  background-color: #000099;
}

.chaos-expert-fork-ribbon.yellow:before {
  background-color: #ffb60b;
}

.chaos-expert-fork-ribbon.silver:before{
  background-color: #b4b4b4;
}

.chaos-expert-fork-ribbon.grey:before{
  background-color: #959bb5;
}

.chaos-expert-fork-ribbon.orange:before{
  background-color: #ff6e40;
}

.chaos-expert-fork-ribbon.white:before{
  -webkit-box-shadow: 0 .15em .23em 0 rgba(255, 255, 255, 0.5);
  -moz-box-shadow: 0 .15em .23em 0 rgba(255, 255, 255, 0.5);
  box-shadow: 0 .15em .23em 0 rgba(255, 255, 255, 0.5);
  background-color: #fff;
}

.chaos-expert-fork-ribbon.white:after{
  color: #000;
  border-color: #333;
}
EOF
}

emit_html()
{
  echo "<!DOCTYPE html><html lang=en><head><title>gcalcli-html-export</title>"
  echo "<meta charset='UTF-8'>"
  echo "<style>"
  echo ".table th {"
  echo "  background-color: #fff;"
  echo "  font-size: 6pt;"
  echo "}"

  [ -n "$ERROR" ] && ribbon_css

  echo "</style>"
  echo "</head><body bgcolor=white>"

  [ -n "$ERROR" ] && echo "<a class='chaos-expert-fork-ribbon' href='#' title='$ERROR'>$ERROR</a>"

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
  } done <"$GCAL_PLAINTEXT" >"$TEMP"

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

rm -f "$TEMPFILE" "$TEMPFILE.html" "$TEMPFILE.png" "$IMAGE" "$GCAL_PLAINTEXT" "$TEMP"
