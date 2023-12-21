# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$HOME/.dotfiles/scripts:/opt/rez/bin/rez/:$PATH"
fi
export PATH
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH
export PATH=$PATH:$GOPATH/bin
export PATH=$HOME/.dotfiles/scripts/:$PATH
export PATH=$HOME/.cargo/bin:$PATH
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

for DOTFILE in `find $HOME/.dotfiles/bash_config`
do
	[ -f "$DOTFILE" ] && . "$DOTFILE"
done

bind -f $HOME/.inputrc

export BG=light
current_theme=`sed -n "2p" $HOME/.config/kitty/current-theme.conf`
if [[ "$current_theme" == *"Dark"* ]];
then
    export BG=dark
fi

# Github/Bitbucket accounts for git
export BITBUCKET_NAME="Victor Fleury"
export BITBUCKET_EMAIL="vfleury@rodeofx.com"
export GITHUB_NAME="Victor Fleury"
export GITHUB_EMAIL="victor.fleury@gmail.com"
export VPN_STATUS_NOTIFICATION=0

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Load pyenv-virtualenv automatically by adding
# the following to ~/.bashrc:

# eval "$(pyenv virtualenv-init -)"
eval "$(zoxide init bash)"
