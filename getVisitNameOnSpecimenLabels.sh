#!/bin/bash

SPECIMEN_LABELS=$1

DB_USER=root
DB_PASS=secrete
DB_HOST=localhost
DB_NAME=os_mysql
OUTPUT_FILE=/home/krishagni/Desktop/Find-Scripts/visits.csv

if [ ! -f $SPECIMEN_LABELS ]
then 
    echo "Please provide specimen Labels FILE."
    exit
fi

while read LABELS; do mysql -u$DB_USER -p$DB_PASS -h$DB_HOST -D$DB_NAME -e "SELECT NAME,LABEL FROM catissue_specimen_coll_group SG, catissue_specimen CS where (SG.IDENTIFIER = CS.SPECIMEN_COLLECTION_GROUP_ID AND CS.LABEL='$LABELS');" >> $OUTPUT_FILE; done < $SPECIMEN_LABELS

sed -i '/NAME/d' $OUTPUT_FILE 
