status=$(nmcli -t -f name,type connection show --order name --active 2>/dev/null | grep vpn | head -1 | cut -d ':' -f 1)
if [[ -z $status ]]; then
    echo " Rodeo"
    notify-send -u critical VPN "VPN was disconnected"
else
    echo " Rodeo"
fi

