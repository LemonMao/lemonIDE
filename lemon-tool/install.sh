#!/bin/bash


#showHelp
#read -p "Please choose usage (bak/auto):" usage
#echo "Now doint it  .... ...."
#echo " "

#set -x
############ Local varibal
srcPluginPath="../myplugin"
dstPluginPath=~/.vim/bundle


############ backup the old vim stuff
mkdir -p ~/vim-bak
mv ~/.vimrc ~/vim-bak/vimrc.bak
#rm ~/.vim/* -rf

############ install lemon vim stuff
ln -s ../vimrc ~/.vimrc
mkdir -v $dstPluginPath/
cd $dstPluginPath
git clone https://github.com/gmarik/vundle.git
cd -
#cp $srcPluginPath/vundle $dstPluginPath/vundle
#cp ../bundle ~/.vim/ -rf
#cp ../lemon-tool ~/.vim/ -rf
#cp ../doc ~/.vim/ -rf

###########  Install plugins online
echo "Get in the VIM to install plugin with BundleInstall command ..."
sleep 3
vim

###########  install myself theme
cp $srcPluginPath/desertmss.vim $dstPluginPath/desertEx/colors/

###########  Customize private plugins 
echo "Modify the mark.vim , comment the 95 lines"
sleep 2
vim $dstPluginPath/Mark/plugin/mark.vim

echo "Copy the c&sh snippets.."
sleep 2
cp $srcPluginPath/c.snippets $srcPluginPath/sh.snippets $dstPluginPath/snipMate/snippets/
echo " "

########### Other actions
echo "Manual actions:"
echo "1. Add private bin path '~/.vim/lemon-tool/' to PATH"

