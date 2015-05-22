#!/bin/bash 
# Script to crop an image from a url into the right resolutions for 3 monitors. 
# play with the variables to match your resolutions for each monitor. 
# the heightOffset variables help you make sure it all lines up as you want. 
# This script needs imageMagick to be installed 

if [ $1 == "" ]; 
then
    echo "Please specify url of the image to resize. eg ./cropper.sh http://i.imgur.com/yGBL5zc.jpg "; 
fi;

export leftWidth=1600;
export leftHeight=900;
export leftHeightOffset=0;

export midWidth=1920;
export midHeight=1200;
export midHeightOffset=0;

export rightWidth=1600;
export rightHeight=900;
export rightHeightOffset=0;

let totalSize=$leftWidth+$midWidth+$rightWidth; 
export totalSize; 

function resizeImage { 
    #resize image so it fits 
      convert $fname  -resize "$totalSize"x $fname
}

function getImage { 
    echo Fetching Image...
    curl --silent -O $1 ;
    echo $fname saved. 
}

function splitImage { 
    echo Splitting Image $fname
    widthOffset=0; 
    dim="$leftWidth"x"$leftHeight"+"$widthOffset"+"$leftHeightOffset"

    convert $fname -crop $dim +repage left_$fname;

    let widthOffset=$widthOffset+$leftWidth; 
    dim="$midWidth"x"$midHeight"+"$widthOffset"+"$midHeightOffset"
    convert $fname -crop $dim +repage middle_$fname;

    let widthOffset=$widthOffset+$midWidth; 
    dim="$rightWidth"x"$rightHeight"+"$widthOffset"+"$rightHeightOffset"
    convert $fname -crop $dim +repage right_$fname;

    echo Done; 
}

export fname=$(basename $1)
getImage $1;
resizeImage; 
splitImage;


