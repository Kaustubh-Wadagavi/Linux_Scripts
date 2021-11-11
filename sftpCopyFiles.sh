#! /bin/bash

HOST=
USERNAME=
LOG_FILE=copy.log
#PASSWORD=
FILE_COPY_LOCATION=/home/jenkins/test

backupStartTime() {
    echo "#########################################################" &>> $LOG_FILE
    echo "Copying Start Time:" `date +%x-%r` &>> $LOG_FILE
}

backupEndTime() {
    echo "Copying End Time:" `date +%x-%r` &>> $LOG_FILE
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
    sudo expect -c "
    spawn sftp -i /home/krishagni/Desktop/sftp-scripts/jenkins-private $USERNAME@$HOST:$FILE_COPY_LOCATION
    #expect \"password: \"
    #send \"${PASSWORD}\r\"
    expect \"sftp>\"
    send \"put $SUB_DIR/*\r\"
    expect \"sftp>\"
    send \"bye\r\"
    expect \"#\"
    " &>> $LOG_FILE

    if [ $? -ne 0 ]; then
      echo "Copying failed file :" $FILE &>> $LOG_FILE
      backupFailedTime
    else
      echo "Successfully copied file :" $FILE &>> $LOG_FILE
      backupEndTime
      #mv $SUB_DIR/ /usr/local/openspecimen/data/copied-print-labels      
    fi
  done
done

rm $LOCK_FILE
