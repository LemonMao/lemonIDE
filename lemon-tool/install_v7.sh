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

###########  Customize private plugins 
# my theme
cp $srcPluginPath/desertmss.vim $dstPluginPath/desertEx/colors/
# tmux config
[ -e ~/.tmux.conf ] && mv ~/.tmux.conf $vimbak/tmux.conf-bak
ln -s $srcPluginPath/tmux.conf ~/.tmux.conf
# bash alias
#[ -e ~/.bash_aliases ] && cat $srcPluginPath/bash_aliases >> ~/.bash_aliases || ln -s $srcPluginPath/bash_aliases ~/.bash_aliases
read -e -p "Shell alias config, additional apply[Y/n]:" ret
if [[ $ret != "n" ]] ; then
    cat $srcPluginPath/lemon_bashrc >> ~/.bashrc
fi
# Bookmark
[ -e ~/.NERDTreeBookmarks ] && mv ~/.NERDTreeBookmarks $vimbak/NERDTreeBookmarks-bak
ln -s $srcPluginPath/NERDTreeBookmarks ~/.NERDTreeBookmarks
# c&sh snippets.
[ -e $dstPluginPath/snipMate/snippets/c.snippets ] && mv $dstPluginPath/snipMate/snippets/c.snippets $vimbak/
[ -e $dstPluginPath/snipMate/snippets/sh.snippets ] && mv $dstPluginPath/snipMate/snippets/sh.snippets $vimbak/
ln -s $srcPluginPath/c.snippets  $dstPluginPath/snipMate/snippets/c.snippets 
ln -s $srcPluginPath/sh.snippets $dstPluginPath/snipMate/snippets/sh.snippets
#[ -e  ] && mv 


ln -s ~/.vim/vimrc_v7 ~/.vimrc 
vim +PlugInstall +qall

