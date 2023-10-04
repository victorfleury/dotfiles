#!/usr/bin/bash
artist=$(playerctl --player=spotify metadata --format "{{ artist }}")
title=$(playerctl --player=spotify metadata --format "{{ title }}")
status=$(playerctl --player=spotify status)
if [[ $status == *"Paused"* ]];then
    icon=""
else
    icon=""
fi
echo " $icon $artist - ${title:0:25}"
