#!/usr/bin/sh

volume_change=$1
#echo "Volume change to $volume_change"

if [[ $volume_change == "up" ]];then
    #echo "In here"
    $(pactl set-sink-volume @DEFAULT_SINK@ +5%)
elif [[ $volume_change == "down" ]];then
    #echo "IN THERE"
    $(pactl set-sink-volume @DEFAULT_SINK@ -5%)
fi
new_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | cut -d "/" -f2,3| xargs| cut -d "," -f1|xargs)
percent=${new_volume%/*}
db=${new_volume#*/}
#echo "Percent ${percent:0:2}"
#echo "DB $db"
$(dunstify --replace=111111 -u low "Volume change" "Volume set to $percent : $db" -h int:value:$percent)
