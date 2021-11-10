#! /bin/bash

LOG_FILE=copy.log

backupStartTime() {
    echo "-----------------------------------------------------" &>> $LOG_FILE
    echo "Copying Start Time:" `date +%x-%r` &>> $LOG_FILE
}

backupEndTime() {
    echo "Copying End Time:" `date +%x-%r` &>> $LOG_FILE
    echo "-----------------------------------------------------" &>> $LOG_FILE
}
backupFailedTime() {
    echo "Copying failed time:" `date +%x-%r` &>> $LOG_FILE
}

backupStartTime

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

   sudo scp -i /home/krishagni/Desktop/sftp-scripts/jenkins-private $FILE jenkins@build.openspecimen.orgs:/home/jenkins/test &>> $LOG_FILE

    if [ $? -ne 0 ]; then
      backupFailedTime
    else
      backupEndTime            
    fi
  done
done

rm $LOCK_FILE


