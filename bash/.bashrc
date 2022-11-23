# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$HOME/.dotfiles/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
#if [ -d ~/.bashrc.d ]; then
#	for rc in ~/.bashrc.d/*; do
#		if [ -f "$rc" ]; then
#			. "$rc"
#		fi
#	done
#fi

# unset rc

for DOTFILE in `find /home/victor/.dotfiles/bash_config`
do
	[ -f "$DOTFILE" ] && . "$DOTFILE"
done

bind -f /home/victor/.inputrc

export BG=light
current_theme=`sed -n "2p" .config/kitty/current-theme.conf`
if [[ "$current_theme" == *"Dark"* ]];
then
    export BG=dark
fi
