# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

for DOTFILE in `find /home/victor/.dotfiles`
do
    [ -f "$DOTFILE" ] && source "$DOTFILE"
done

