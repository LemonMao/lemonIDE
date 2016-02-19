#!/bin/bash


#showHelp
#read -p "Please choose usage (bak/auto):" usage
#echo "Now doint it  .... ...."
#echo " "

#set -x

# backup the old vim stuff
mkdir ~/vim-bak
cp ~/.vimrc ~/.vim ~/vim-bak/ -rf
# install lemon vim stuff
cp ../vimrc ~/.vimrc
cp ../bundle ~/.vim/ -rf
cp ../lemon-tool ~/.vim/ -rf




