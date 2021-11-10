#! /bin/bash

LOCK_FILE=/tmp/print_lock.txt 

if [ -e $LOCK_FILE ] && kill -0 `cat $LOCK_FILE`; then
  exit                                 
fi

trap "rm -f $LOCK_FILE; exit" INT TERM EXIT

echo $$ > $LOCK_FILE

for SUB_DIR in `ls -d /usr/local/openspecimen/data/print-labels/*`
do
  for FILE in `ls -tr $SUB_DIR/*`        
  do
   sudo scp -i /home/krishagni/Desktop/sftp-scripts/jenkins-private $FILE jenkins@build.openspecimen.org:/home/jenkins/test
    if [ $? -ne 0 ]; then
      echo "Failed to copy the file"  
    else
      echo "File copied successfully"            
    fi
  done
done

rm $LOCK_FILE
