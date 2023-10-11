result=$(echo -e "\uf023 Lock\n\uf08b Logout\n Shutdown\n\uead2 Reboot"| rofi -no-config -theme ~/.config/polybar.old2/material/scripts/rofi/powermenu.rasi -p "Uptime : $(uptime -p | sed -e 's/up //g')" -dmenu -selected-row 0)
filtered=${result:2}

dir="~/.config/polybar.old2/material/scripts/rofi"
# Confirmation
function confirm_exit() {
    rofi -dmenu\
        -no-config\
        -i\
        -no-fixed-num-lines\
        -p "Are You Sure? (Y)es or (N)o :"\
        -theme $dir/confirm.rasi
}

# Message
msg() {
    rofi -no-config -theme "$dir/message.rasi" -e "Available Options  -  yes / y / no / n"
}

case $filtered in
    Lock)
        echo "Locking session"
        betterlockscreen -l blur
        ;;
    Logout)
        ans=$(confirm_exit &)
        echo "Ans is $ans"
        if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
            echo "Logging out of session"
            i3-msg exit
        elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" || $ans == "" ]]; then
            exit 0
        else
            msg
        fi
        ;;
    Shutdown)
        ans=$(confirm_exit &)
        if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
            echo "Shutting down"
            systemctl poweroff
        elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" || $ans == "" ]]; then
            exit 0
        else
            msg
        fi
        ;;
    Reboot)
        ans=$(confirm_exit &)
        if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
            echo "Rebooting"
            systemctl reboot
        elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" || $ans == "" ]]; then
            exit 0
        else
            msg
        fi
        ;;
esac
