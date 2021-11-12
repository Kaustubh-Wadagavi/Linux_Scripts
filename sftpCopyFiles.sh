#! /bin/bash

HOST=build.openspecimen.org
USERNAME=jenkins
#PASSWORD=
TARGET_LOCATION=/home/jenkins/test
EXISTING_LOCATION=/usr/local/openspecimen/data/print-labels/*
LOG_FILE=copy.log

printToLog() {
    echo "$(date +%F-%T)-INFO-${log}"&>> $LOG_FILE
}

connectToSftp() {
      sudo expect -c "
        spawn sftp -i /home/krishagni/Desktop/sftp-scripts/jenkins-private $USERNAME@$HOST
        #expect \"password: \"
        #send \"${PASSWORD}\r\"
        expect \"sftp>\"
     "
}

disConnectSftp() {
	expect -c "
	 expect \"sftp>\"
 	 send \"bye\r\"
         expect \"#\"
     	"
}

LOCK_FILE=/tmp/print_lock.txt 
log="locking file ...."
printToLog

if [ -e $LOCK_FILE ] && kill -0 `cat $LOCK_FILE`; then
  exit                                 
fi

trap "rm -f $LOCK_FILE; exit" INT TERM EXIT
log="successfully locked file.."
printToLog

echo $$ > $LOCK_FILE

connectToSftp

for SUB_DIR in `ls -d $EXISTING_LOCATION`
do  
  log="Processing Directory:${SUB_DIR}"
  printToLog
    for SUB_DIR_FILE in `ls -tr $SUB_DIR/*`        
    do
      log="Processing file: ${SUB_DIR_FILE}"
      printToLog
      sudo expect -c "
      expect \"sftp>\"
      send \"cd ${TARGET_LOCATION}\r\"
      expect \"sftp>\"
      #send \"mkdir ${SUB_DIR##*/}\r\"
      #expect \"sftp>\"
      #send \"cd ${SUB_DIR##*/}\r\"
      #expect \"sftp>\"
      send \"put ${SUB_DIR_FILE}\r\"
     "
     #mv $SUB_DIR/ /usr/local/openspecimen/data/copied-print-labels      
  done
done

disConnectSftp

rm $LOCK_FILE
log="Released lock file..."
printToLog
