#!/bin/sh

DOTFILES_HOME="$(dirname $(readlink -f "$0"))"

cd $DOTFILES_HOME

backup() {
    # If the file doesn't exist we don't need to back it up
    [ -f "$1" ] || return 0 
    # Try moving the file: if that fails for some reason (e.g. backup file not
    # writable) backing up failed
    mv -i "$1" "$1.bak" || return -1
    # If the file still exists, fail. The user may have said no to the
    # overwrite prompt if the backup file already existed
    [ -f "$1" ] && return -1
}

backup ~/.bashrc || exit -1
backup ~/.zshrc || exit -1
backup ~/.Xresources || exit -1

# Now we can safely proceed, the files have been backed up
echo "export DOTFILES_HOME='$DOTFILES_HOME'" | tee ~/.bashrc > ~/.zshrc
echo 'source $DOTFILES_HOME/bashrc' >> ~/.bashrc
echo 'source $DOTFILES_HOME/zshrc' >> ~/.zshrc

ln -s "$DOTFILES_HOME/Xresources" ~/.Xresources
