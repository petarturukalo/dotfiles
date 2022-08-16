#! /bin/sh
# Deploy dotfiles to the current user's home directory.
FILES=(bashrc ctags tmux.conf vimrc)

for f in ${FILES[@]}; do
	ln -is $PWD/$f $HOME/.$f
done
