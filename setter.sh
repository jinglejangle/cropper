#!/bin/bash 

function setRemoteBgXFCE { 

    rfname=$(basename $1)

    if [ -e "./$1" ] ; 
    then 
        scp $1 $remoteHost:$remotePath && 
        ssh -x venus "export DISPLAY=:0.0 ; xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -n -t string -s $remotePath/$rfname "
    else 
        echo "./$1 does not exist. problem setting remote bg"; 
        ls -la $1;
        exit 1; 

    fi

}

function setLocalBgOSX { 
    cwd=`pwd`; 
    echo "setting OSX bg for desktop $2 to $1"; 
    echo osascript -e "tell application \"System Events\" to set picture of desktop $2 to \"$cwd/$1\"" ; 
    osascript -e "tell application \"System Events\" to set picture of desktop $2 to \"$cwd/$1\"" ; 
}
