#! /bin/bash
# Deploy dotfiles to the current user's home directory.
FILES=(bashrc ctags tmux.conf)

for f in ${FILES[@]}; do
	ln -vis $PWD/$f ~/.$f
done
mkdir -vp ~/.vim
ln -vis $PWD/vimrc ~/.vim/vimrc
