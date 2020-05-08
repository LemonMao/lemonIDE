#!/bin/bash


#showHelp
#read -p "Please choose usage (bak/auto):" usage
#echo "Now doint it  .... ...."
#echo " "

#set -x
############ Local varibal
srcPluginPath=~/.vim/myplugin
dstPluginPath=~/.vim/plugged
vimbak=~/vim-bak
vimrc=~/.vimrc 

rm -rf $dstPluginPath/gutentags_plus
rm -rf $dstPluginPath/vim-gutentags
rm -rf $dstPluginPath/vim-preview
rm ~/.vimrc
ln -s ~/.vim/vimrc_v7 ~/.vimrc 
vim +PlugInstall +qall

