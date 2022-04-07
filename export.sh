#!/bin/bash

DB_USER=
DB_PASS=
DB_NAME=
INPUT_FILE=
OUTPUT_PATH=

while IFS="," read -r tableName
do
   mysql -uroot -psecrete os_mysql -e "select * from $tableName;" > $OUTPUT_PATH$tableName.csv
done < $INPUT_FILE
