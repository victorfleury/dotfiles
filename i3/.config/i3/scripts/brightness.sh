brightness_change=$1

if [[ $brightness_change == "up" ]];then
    $(brightnessctl set +10%)
elif [[ $brightness_change == "down" ]];then
    $(brightnessctl set 10%-)
fi
current_brightness=$(brightnessctl i | tr -d "\n" | xargs | cut -d "(" -f2 | xargs | cut -d ")" -f 1)
percent=${current_brightness%/*}
$(dunstify --replace=222222 -i /usr/share/icons/Papirus/16x16/apps/display-brightness.svg -u low "Brightness change" "Brightness set to $current_brightness" -h int:value:$percent)
