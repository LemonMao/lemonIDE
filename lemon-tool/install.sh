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
[ -e ~/.tmux.conf.local ] && mv ~/.tmux.conf.local $vimbak/tmux.conf.local-bak
read -e -p "Install tmux config? [Y/n]" ret
if [[ $ret != "n" ]] ; then
    git clone https://github.com/gpakosz/.tmux.git ~/.tmux
    ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf
    echo -e "\n\nComment 14/19/20 line for git status and repalce resize-pane from 2 to 5" && sleep 2
    vim +14 ~/.tmux.conf
fi
ln -s -f $srcPluginPath/tmux.conf.local ~/.tmux.conf.local

# bash-it config
[ -e ~/.bash_aliases ] && mv ~/.bash_aliases $vimbak/bash_aliases-bak
#ln -s -f $srcPluginPath/bash_aliases ~/.bash_aliases
read -e -p "Install bash-it ? [Y/n]" ret
if [[ $ret != "n" ]] ; then
    [ -e ~/.bash_it ] && mv ~/.bash_aliases $vimbak/bash_it-bak
    git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
    cd ~/.bash_it/ && ./install.sh
    echo -e "\n\nComment 116 line for git status" && sleep 2
    vim +116 .bash_it/themes/powerline/powerline.base.bash
    bash-it enable completion git docker ssh tmux pip makefile
    bash-it enable plugin man docker history-eternal less-pretty-cat ssh history history-substring-search history-search colors
    mkdir -p ~/.bash_it/custom
    ln -s -f $srcPluginPath/bash_aliases ~/.bash_it/custom/bash_aliases.bash
fi

# Bookmark
[ -e ~/.NERDTreeBookmarks ] && mv ~/.NERDTreeBookmarks $vimbak/NERDTreeBookmarks-bak
ln -s $srcPluginPath/NERDTreeBookmarks ~/.NERDTreeBookmarks
# c&sh snippets.
rm -rf $dstPluginPath/snipMate/snippets/c.snippets && ln -s $srcPluginPath/c.snippets  $dstPluginPath/snipMate/snippets/c.snippets
rm -rf $dstPluginPath/snipMate/snippets/cpp.snippets && ln -s $srcPluginPath/cpp.snippets  $dstPluginPath/snipMate/snippets/cpp.snippets
rm -rf $dstPluginPath/snipMate/snippets/sh.snippets && ln -s $srcPluginPath/sh.snippets $dstPluginPath/snipMate/snippets/sh.snippets

#echo "Comment the 122 lines of vimrc"
#sleep 2
#vim +122 ~/.vimrc
#echo " "

echo -e "\n\nComment the 95 lines of mark.vim file" && sleep 2
vim +95 $dstPluginPath/Mark/plugin/mark.vim
echo -e "\n\nAdd '--skip-unreadable', option for gtags" && sleep 2
vim +91 $dstPluginPath/vim-gutentags/autoload/gutentags/gtags_cscope.vim
#let l:cmd += ['--incremental', '--skip-unreadable', '"'.l:db_path.'"']
echo " "


########### Other actions
echo "Manual actions:"
echo "1. Git config apply"

