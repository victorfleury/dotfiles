# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Sourcing cargo stuff for adding custom crate tools installed in $HOME/.cargo/bin
. "$HOME/.cargo/env"

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

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Sourcing various bash configurations / custom scripts
for DOTFILE in `find $HOME/.dotfiles/bash_config`
do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
done

# Adding .inputrc for arrow up/down history search
bind -f $HOME/.inputrc

# PYENV setup to manage multiple python versions
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Load pyenv-virtualenv automatically by adding
# the following to ~/.bashrc:
eval "$(pyenv virtualenv-init -)"

# 3rd party tools
# Setup fzf
# ---------
if [[ ! "$PATH" == *$HOME/.dotfiles/tools/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.dotfiles/tools/fzf/bin"
fi

# fzf
eval "$(fzf --bash)"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Sourcing external tools ie : fzf-git.sh
. "$HOME/.dotfiles/tools/fzf-git.sh/fzf-git.sh"
# zoxide
eval "$(zoxide init bash)"
# starship
eval "$(starship init bash)"

# Bat stuff
export BAT_THEME=gruvbox-dark
