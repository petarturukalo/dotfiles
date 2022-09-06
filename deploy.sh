#! /bin/bash
# Deploy dotfiles to the current user's home directory.
FILES=(bashrc ctags tmux.conf)

for f in ${FILES[@]}; do
	ln -vis $PWD/$f $HOME/.$f
done
mkdir -vp $HOME/.vim
ln -is $PWD/vimrc $HOME/.vim/vimrc
