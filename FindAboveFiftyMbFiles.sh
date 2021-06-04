#! /bin/bash

fileExtension=$1
fileSize=$2

if [ "$#" -ne 2 ]
then
        echo "Please enter 1.File extension and 2.File size through command line!!"
else
        sudo find / -type f -name '*.'$fileExtension'' -size +50M -exec ls -sh {} \;
fi

