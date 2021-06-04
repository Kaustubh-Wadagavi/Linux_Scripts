#! /bin/bash

fileExtension=$1
fileSize=$2

if [ "$#" -ne 2 ]
then
        echo "Please enter 1.File extension and 2.File size through command line!!"
else
	sudo find / -type f -name '*.'zip'' -size +50M | xargs ls -ltr -h | awk '{print $5,$6,$7,$8,$9}'
fi

