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
mkdir -p $vimbak
[ -e $vimrc ] && mv $vimrc $vimbak/vimrc.bak
#rm ~/.vim/* -rf

############ install lemon vim stuff
ln -s ~/.vim/vimrc $vimrc
mkdir -v $dstPluginPath/
#git clone https://github.com/gmarik/vundle.git $dstPluginPath/vundle/
#git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
#curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
#[ $? -ne 0 ] && echo "!!!!  Install vindle tool failed !" && exit
echo " "
#cp $srcPluginPath/vundle $dstPluginPath/vundle
#cp ../bundle ~/.vim/ -rf
#cp ../lemon-tool ~/.vim/ -rf
#cp ../doc ~/.vim/ -rf

###########  Install plugins online
read -e -p "Remotely install plugin [Y/n]" ret
if [[ $ret != "n" ]] ; then
    vim +PlugInstall +qall
    echo " "
else
    cd ~/.vim/
    tar zxvf plugged.tar.gz 
    cd -
fi

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
rm -rf $dstPluginPath/snipMate/snippets/c.snippets && ln -s $srcPluginPath/c.snippets  $dstPluginPath/snipMate/snippets/c.snippets 
rm -rf $dstPluginPath/snipMate/snippets/cpp.snippets && ln -s $srcPluginPath/cpp.snippets  $dstPluginPath/snipMate/snippets/cpp.snippets 
rm -rf $dstPluginPath/snipMate/snippets/sh.snippets && ln -s $srcPluginPath/sh.snippets $dstPluginPath/snipMate/snippets/sh.snippets
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

