status=$(nmcli -t -f name,type connection show --order name --active 2>/dev/null | grep vpn | head -1 | cut -d ':' -f 1)
VPN_STATUS_NOTIFICATION=$(head -n 1 ~/.vpn_status)
if [[ -z $status ]]; then
    echo " Rodeo"
    if [[ $VPN_STATUS_NOTIFICATION == 1 ]]; then
        notify-send -u critical VPN "VPN was disconnected"
        echo "0" >| ~/.vpn_status
    fi
else
    if [[ $VPN_STATUS_NOTIFICATION == 0 ]];then
        notify-send VPN "Successfully connected to VPN"
        echo "1" >| ~/.vpn_status
    fi
    echo " Rodeo"
fi

