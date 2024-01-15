#status=$(nmcli -t -f name,type connection show --order name --active 2>/dev/null | grep vpn | head -1 | cut -d ':' -f 1)
#VPN_STATUS_NOTIFICATION=$(head -n 1 ~/.vpn_status)
#if [[ -z $status ]]; then
    #echo " Rodeo"
    #if [[ $VPN_STATUS_NOTIFICATION == 1 ]]; then
        #notify-send -u critical VPN "VPN was disconnected"
        #echo "0" >| ~/.vpn_status
    #fi
#else
    #if [[ $VPN_STATUS_NOTIFICATION == 0 ]];then
        #notify-send VPN "Successfully connected to VPN"
        #echo "1" >| ~/.vpn_status
    #fi
    #echo " Rodeo"
#fi


function connect() {
    echo "Connecting to VPN"
    result=$(nmcli con up id RodeoFX)
    echo "THIS IS RESULT $result"
    if grep -q "successfully activated" <<< $result; then
        notify-send "Rodeo VPN Status" "Successfully connected to VPN RodeoFX"
        echo "1" >| ~/.vpn_status
    else
        notify-send -u critical VPN "Rodeo VPN Status" "Could not connect to VPN RodeoFX"
        echo "0" >| ~/.vpn_status
    fi
}

function disconnect() {
    echo "Disconnecting from VPN"
    result=$(nmcli con down id RodeoFX)
    echo "THIS IS RESULT $result"
    if grep -q "successfully deactivated" <<< $result; then
        notify-send "Rodeo VPN Status" "Successfully disconnected from VPN"
        echo "0" >| ~/.vpn_status
    else
        notify-send "Rodeo VPN Status" "Could not disconnect VPN ?"
        echo "1" >| ~/.vpn_status
    fi
}

function status(){
    status=$(nmcli -t -f name,type connection show --order name --active 2>/dev/null | grep vpn | head -1 | cut -d ':' -f 1)
    VPN_STATUS_NOTIFICATION=$(head -n 1 ~/.vpn_status)
    if [[ -z $status ]]; then
        echo " Rodeo"
    else
        echo " Rodeo"
    fi
}


function main(){
    case $1 in
        -c | --connect)
            connect
            ;;
        -d | --disconnect)
            disconnect
            ;;
        *)
            status
            ;;
    esac
}

main $1

