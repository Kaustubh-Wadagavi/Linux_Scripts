#!/bin/bash

source /usr/local/openspecimen/sftp-scripts/config.txt

COUNT=$(find $SOURCE_DIR -type f | wc -l)

if [[ $COUNT -eq 0 ]]
then
    exit
fi

if [ -e $LOCK_FILE ] && kill -0 `cat $LOCK_FILE`; then
  exit
fi

trap "rm -f $TEMP_FILE" 0 1 15
trap "rm -f $LOCK_FILE; exit" INT TERM EXIT
echo $$ > $LOCK_FILE

SUB_DIR= find $SOURCE_DIR* -maxdepth 1 -type d | while read SUB_DIR
do 
  REMOTE_DIR=${SUB_DIR/$SOURCE_DIR}
  FILE= find "${SUB_DIR}"/* -maxdepth 1 -type f | while read FILE
  do
   if [[ ! -d "$FILE" ]]
   then 
      echo "put '$FILE' '$REMOTE_DIR'" >> $TEMP_FILE
   fi
  done
done

echo "quit" >> $TEMP_FILE   

echo "$(date +%F-%T)-INFO- Synchronizing: Found $COUNT files in local folder to upload."

sudo sftp -i /home/krishagni/jenkins-private -b $TEMP_FILE -v "$USER@$HOST"
SFTP_EXIT_CODE=$?
 
if [[ $SFTP_EXIT_CODE -eq 0 ]]
then
    SUB_DIR= find $SOURCE_DIR* -maxdepth 1 -type d | while read SUB_DIR
    do
       DIR=${SUB_DIR/$SOURCE_DIR}
       if [ -d "$MOVING_FILES_LOCATION/${DIR}" ]
       then
	 echo "$SORCE_DIR/${DIR}"
         mv "$SUB_DIR"/* "$MOVING_FILES_LOCATION/${DIR}"
       else
         mkdir -p "$MOVING_FILES_LOCATION/${DIR}"
         mv "$SUB_DIR"/* "$MOVING_FILES_LOCATION/${DIR}"
       fi
    done
else
    echo "sftp is failed: Send mail"
fi

echo "SFTP EXIT CODE IS: $SFTP_EXIT_CODE"

rm -f $TEMP_FILE
rm -f $LOCK_FILE

exit 0
