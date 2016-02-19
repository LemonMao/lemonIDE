#!/bin/bash

function showHelp()
{
    echo "<-----lemon IDE install usage:----->"
    echo "=install.sh bak"
    echo -e "\tuse: backup my .vim and .vimrc environment and tar to lemonIDE.tar.gz"
    echo "=install.sh auto"
    echo -e "\tuse: install lemonIDE to your environment"
    echo "-----------------------------"

}

showHelp
read -p "Please choose usage (bak/auto):" usage
echo "Now doint it  .... ...."
echo " "

oriDir=$(pwd)
echo $oriDir
objDir="/tmp/lemonIDE"
#set -x
case $usage in
    "bak")
        #{{{  install new files
        echo "Tar lemonIDE..."
        rm $objDir -rf
        mkdir $objDir ||  exit
        cp -rf ~/.vim $objDir/vimfiles
        cp ~/.vimrc $objDir/vimrc 
        #cp ~/.vim/shell/install.sh $objDir/install.sh
        find $objDir/vimfiles -type d -name '.svn' | xargs rm -rf
        cd $objDir
        cp ./vimfiles/shell/install-backup-tool.sh ./
        cd ..
        tar -zcvpf lemonIDE.tar.gz ./lemonIDE 1>/dev/null
        mv ./lemonIDE.tar.gz $oriDir/
        rm -rf $objDir
        echo "Update finished, enjoy yourself!"
        #}}}
        ;;
    "auto")
        #{{{ install new files
        echo "Please backup your old vim files. !!!"
        echo -n "Did you backup your old vim files. [y,n]? "
        read ret
        if test $ret != y ; then
            echo "Install exit."
            exit
        fi

        echo "Install lemonIDE..."
        rm -rf ~/.vim ~/.vimrc
        cp -r ./vimfiles ~/.vim
        cp ./vimrc ~/.vimrc
        echo "done!" 
        echo "Install finished, enjoy yourself!"
        #}}}
        ;;
    *)
        echo "Unkown option ! Excute again !"
        ;;
esac


