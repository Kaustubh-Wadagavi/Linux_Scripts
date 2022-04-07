#!/bin/bash

COLUMN_NAME=$1
DB_NAME=os_mysql
DB_USER=os_tester
DB_PASS=secrete
DB_HOST=localhost

if [ ! -f $COLUMN_NAME ]
then 
    echo "Please provide columns names FILE."
    exit
fi

while read COLUMN_NAME 
do 
   mysql -u$DB_USER -p$DB_PASS -h$DB_HOST -D$DB_NAME -e "UPDATE catissue_participant SET $COLUMN_NAME='' where ACTIVITY_STATUS='DISABLED';"
done < <(tail -n +2 input.csv)
