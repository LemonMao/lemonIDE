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


############ backup the old vim stuff
[ -d $vimbak ] && mkdir -p $vimbak
[ -e $vimrc ] && mv $vimrc ~/vim-bak/vimrc.bak
#rm ~/.vim/* -rf

############ install lemon vim stuff
ln -s ~/.vim/vimrc $vimrc
mkdir -v $dstPluginPath/
#git clone https://github.com/gmarik/vundle.git $dstPluginPath/vundle/
#git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vimcurl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
[ $? -ne 0 ] && echo "!!!!  Install vindle tool failed !"
echo " "
#cp $srcPluginPath/vundle $dstPluginPath/vundle
#cp ../bundle ~/.vim/ -rf
#cp ../lemon-tool ~/.vim/ -rf
#cp ../doc ~/.vim/ -rf

###########  Install plugins online
echo "Get in the VIM to install plugin with BundleInstall command ..."
sleep 3
vim +PlugInstall +qall
echo " "

###########  Customize private plugins 
# my theme
cp $srcPluginPath/desertmss.vim $dstPluginPath/desertEx/colors/
# tmux config
[ -e ~/.tmux.conf ] && mv ~/.tmux.conf $vimbak/tmux.conf-bak
ln -s $srcPluginPath/tmux.conf ~/.tmux.conf
# bash alias
#[ -e ~/.bash_aliases ] && cat $srcPluginPath/bash_aliases >> ~/.bash_aliases || ln -s $srcPluginPath/bash_aliases ~/.bash_aliases
cat $srcPluginPath/lemon_bashrc >> ~/.bashrc
# Bookmark
[ -e ~/.NERDTreeBookmarks ] && mv ~/.NERDTreeBookmarks $vimbak/NERDTreeBookmarks-bak
ln -s $srcPluginPath/NERDTreeBookmarks ~/.NERDTreeBookmarks
# c&sh snippets.
[ -e $dstPluginPath/snipMate/snippets/c.snippets ] && mv $dstPluginPath/snipMate/snippets/c.snippets $vimbak/
[ -e $dstPluginPath/snipMate/snippets/sh.snippets ] && mv $dstPluginPath/snipMate/snippets/sh.snippets $vimbak/
ln -s $srcPluginPath/c.snippets  $dstPluginPath/snipMate/snippets/c.snippets 
ln -s $srcPluginPath/sh.snippets $dstPluginPath/snipMate/snippets/sh.snippets
#[ -e  ] && mv 


#echo "Comment the 122 lines of vimrc"
#sleep 2
#vim +122 ~/.vimrc
#echo " "

echo "Comment the 95 lines of mark.vim file"
sleep 2
vim +95 $dstPluginPath/Mark/plugin/mark.vim
echo " "

########### Other actions
echo "Manual actions:"
echo "1. Git config apply"

