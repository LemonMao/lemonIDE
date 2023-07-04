#!/bin/bash

#set -x
############ Local varibal
srcPluginPath=~/.vim/myplugin
dstPluginPath=~/.vim/plugged
vimbak=~/vim-bak
vimrc=~/.vimrc

retry_command() {
    while true; do
        echo "Prepare to run the command: $1"
        $1
        if [ $? -ne 0 ]; then
            echo "Failed to run the command. Retry. "
            continue
        else
            echo "Successfully to run the command."
            break
        fi
    done

}

############ backup the old vim stuff
mkdir -p $vimbak
mkdir -v $dstPluginPath/
[ -e $vimrc ] && mv $vimrc $vimbak/vimrc.bak
ln -s ~/.vim/vimrc $vimrc

###########  Install plugins
read -e -p "Remotely install plugin [Y/n]" ret
if [[ $ret != "n" ]] ; then
    vim +PlugInstall
    cd ~/.vim/plugged
    tar zxvf ~/.vim/myplugin/vim_dashboard.tar.gz
else
    cd ~/.vim/
    tar zxvf plugged.tar.gz
    cd -
fi

###########  Customize private plugins
# tmux config
read -e -p "\nInstall tmux config? [Y/n]" ret
if [[ $ret != "n" ]] ; then
    retry_command "git clone https://github.com/gpakosz/.tmux.git ~/.tmux"
    #echo -e "\n\nComment 14/19/20 line for git status and repalce resize-pane from 2 to 5" && sleep 2
    #vim +14 ~/.tmux/.tmux.conf
fi
[ -e ~/.tmux.conf ] && mv ~/.tmux.conf $vimbak/tmux.conf-bak
#ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf
ln -s -f $srcPluginPath/tmux.conf ~/.tmux.conf
[ -e ~/.tmux.conf.local ] && mv ~/.tmux.conf.local $vimbak/tmux.conf.local-bak
ln -s -f $srcPluginPath/tmux.conf.local ~/.tmux.conf.local

# bash-it config
[ -e ~/.bash_aliases ] && mv ~/.bash_aliases $vimbak/bash_aliases-bak
#ln -s -f $srcPluginPath/bash_aliases ~/.bash_aliases
read -e -p "Install bash-it ? [Y/n]" ret
if [[ $ret != "n" ]] ; then
    retry_command "git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it"
    read -e -p "Please check if bash_it is installed? [Y/n]" ret
    if [[ $ret != "n" ]]; then
        cd ~/.bash_it/
        ./install.sh
        echo -e "\n\nComment 116 line for git status" && sleep 2
        vim +116 ~/.bash_it/themes/powerline/powerline.base.bash
        bash-it enable completion git docker tmux pip makefile
        bash-it enable plugin man docker history-eternal less-pretty-cat history history-substring-search history-search colors
        mkdir -p ~/.bash_it/custom
        ln -s -f $srcPluginPath/bash_aliases ~/.bash_it/custom/bash_aliases.bash
        echo -e "change BASH_IT_THEME to powerline, and GIT_HOSTING"
    fi
fi

# my theme
cp $srcPluginPath/desertmss.vim $dstPluginPath/desertEx/colors/
# Bookmark
[ -e ~/.NERDTreeBookmarks ] && mv ~/.NERDTreeBookmarks $vimbak/NERDTreeBookmarks-bak
ln -s $srcPluginPath/NERDTreeBookmarks ~/.NERDTreeBookmarks
# c&sh snippets.
rm -rf $dstPluginPath/snipMate/snippets/c.snippets && ln -s $srcPluginPath/c.snippets  $dstPluginPath/snipMate/snippets/c.snippets
rm -rf $dstPluginPath/snipMate/snippets/cpp.snippets && ln -s $srcPluginPath/cpp.snippets  $dstPluginPath/snipMate/snippets/cpp.snippets
rm -rf $dstPluginPath/snipMate/snippets/sh.snippets && ln -s $srcPluginPath/sh.snippets $dstPluginPath/snipMate/snippets/sh.snippets

# comment plugin
read -e -p "\n\nComment the lines in mark.vim file.\n\t=>nmap <unique> <silent> <leader>r <Plug>MarkRegex [Y/n]" ret
if [[ $ret != "n" ]] ; then
    vim +95 $dstPluginPath/Mark/plugin/mark.vim
fi
read -e -p "\n\nAdd '--skip-unreadable', option for gtags\n\t=>#let l:cmd += ['--incremental', '--skip-unreadable', '"'.l:db_path.'"']" ret
if [[ $ret != "n" ]] ; then
    vim +91 $dstPluginPath/vim-gutentags/autoload/gutentags/gtags_cscope.vim
fi
echo " "


########### Other actions
echo "Manual actions:"
echo "1. Git config apply\n\t=> .doc/git.cfg"
echo "2. Change PWD in vimrc\n\t=> .doc/git.cfg"

