#!/usr/bin/bash
#
#status=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus' |grep -o Playing)
#dbus_data=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata')

#artist=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' |sed -n -e "/title/n;28p" |cut -d '"' -f 2)
#track=$(echo "$dbus_data" | sed -n '/title/{n;p}'| cut -d '"' -f 2)

##echo "Status : $status"
##echo "dbus data : $dbus_data"
artist=$(playerctl --player=spotify metadata --format "{{ artist }}")
title=$(playerctl --player=spotify metadata --format "{{ title }}")
status=$(playerctl --player=spotify status)
if [[ $status == *"Paused"* ]];then
    icon=""
else
    icon=""
fi
echo " $icon $artist - ${title:0:25}"
