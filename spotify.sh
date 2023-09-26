#!/usr/bin/bash
#
status=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus' |grep -o Playing)
dbus_data=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata')

#artist=`echo $dbus_data | sed -n '/artist/{n;p}'| cut -d '"' -f 2`
artist=$(echo "$dbus_data" | sed -n '/artist/{n;p}' | cut -d '"' -f 2)
#artist=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' |sed -n -e "/title/n;28p" |cut -d '"' -f 2)
echo $artist

track=$(echo "$dbus_data" | sed -n '/title/{n;p}'| cut -d '"' -f 2)

echo "Status : $status"
#echo "dbus data : $dbus_data"
echo "Currently playing : $artist - $track"
