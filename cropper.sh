#!/bin/bash 
# Script to crop an image from a url into the right resolutions for 3 monitors. 
# play with the variables to match your resolutions for each monitor. 
# the heightOffset variables help you make sure it all lines up as you want. 
# This script needs imageMagick to be installed 
# Configure your screen resolutions and height offsets for them in config.sh 


if [ "$1" == "" ]; 
then
    echo "Please specify url of the image to resize. eg ./cropper.sh http://i.imgur.com/yGBL5zc.jpg "; 
    exit; 
fi;

offset=0; 
if [ "$2" == "--offset" ]; 
then
  offset="$3"; 
fi;


if [ -a config.sh ];
then
    source config.sh 
    source setter.sh 
else
    echo "config.sh is missing"
    exit; 
fi; 
if [ ! -d "$base" ]; then
    echo "$base directory is missing. maybe you should create it first?"; 
    exit; 
fi

let totalSize=$leftWidth+$midWidth+$rightWidth; 
echo "totalSize: $totalSize"
export totalSize; 

let minHeight=$leftHeight; 
if [ $minHeight -lt $midHeight ] ; then 
    let minHeight=$midHeight; 
fi;
if [ $minHeight -lt $rightHeight ] ; then 
    let minHeight=$rightHeight; 
fi;

echo "Min height is $minHeight"; 

function resizeImage { 
    #resize image so it fits 
      convert "$base"$fname  -resize "$totalSize"x "$base"$fname

    imageSize=`identify $base$fname | awk '{print $3}'`; 
    echo "Size is now $imageSize";
     
    let imageHeight=`echo $imageSize | awk -Fx '{print $2}'`; 

    if [ $imageHeight -lt $minHeight ]; then 

        echo "Height is not enough for minimum. Add more size!"; 
        convert "$base"$fname  -resize x$minHeight "$base"$fname
        imageSize=`identify $base$fname | awk '{print $3}'`; 
        echo "Resize is now $imageSize";
   fi; 
}


function getImage { 
    echo Fetching Image...
    curl --silent -O $1 && mv "$fname" "$base"
    echo $fname saved. 
}

function splitImage { 
    echo Splitting Image $fname
    widthOffset=0; 
    dim="$leftWidth"x"$leftHeight"+"$widthOffset"+"$leftHeightOffset"

    convert "$base"$fname -crop $dim +repage "$base"left_$fname;

    let widthOffset=$widthOffset+$leftWidth; 
    dim="$midWidth"x"$midHeight"+"$widthOffset"+"$midHeightOffset"
    convert "$base"$fname -crop $dim +repage "$base"middle_$fname;

    let widthOffset=$widthOffset+$midWidth; 
    dim="$rightWidth"x"$rightHeight"+"$widthOffset"+"$rightHeightOffset"
    convert "$base"$fname -crop $dim +repage "$base"right_$fname;

    echo Done; 
}

export fname=$(basename $1)
getImage $1;
resizeImage; 
splitImage;

#Set the wallpapers using functions in setter.sh  
setRemoteBgXFCE $base"$remote_position"_"$fname"; 
setLocalBgOSX $base"middle_"$fname "1";
setLocalBgOSX $base"right_"$fname "2";
