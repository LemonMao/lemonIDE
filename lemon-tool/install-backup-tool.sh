#!/bin/bash


#showHelp
#read -p "Please choose usage (bak/auto):" usage
#echo "Now doint it  .... ...."
#echo " "

#set -x

# backup the old vim stuff
mkdir ~/vim-bak
cp ~/.vimrc ~/.vim ~/vim-bak/ -rf
rm ~/.vim/* -rf
# install lemon vim stuff
cp ../vimrc ~/.vimrc
cp ../bundle ~/.vim/ -rf
cp ../lemon-tool ~/.vim/ -rf
cp ../doc ~/.vim/ -rf

echo "Get in the VIM to install plugin with BundleInstall command ..."
sleep 3
vim
cp ../bundle/desertmss.vim ~/.vim/bundle/desertEx/colors/
echo "Modify the mark.vim , comment the 95 lines"
sleep 2
vim ~/.vim/bundle/Mark/plugin/mark.vim

echo "Copy the c&sh snippets.."
sleep 2
cp ../bundle/c.snippets ../bundle/sh.snippets ~/.vim/bundle/snipMate/snippets/

