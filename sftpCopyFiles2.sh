#!/bin/bash

HOST=
USERNAME=
PASSWORD=
EXISTING_LOCATION=
LOG_FILE=/usr/local/os-test/copy.log
MOVING_FILES_LOCATION=
log=""

printToLog() {
   echo "$(date +%F-%T)-INFO-${log}" >> $LOG_FILE
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

for SUB_DIR in `ls -d $EXISTING_LOCATION/*`
do
  log="Processing Directory:${SUB_DIR}"
  printToLog

  for SUB_DIR_FILE in `ls -tr $SUB_DIR/*`
  do
   log="Processing file: ${SUB_DIR_FILE}"
   printToLog

    expect -c "
    spawn sftp UTSHB@129.106.148.161
    expect \"password: \"
    send \"${PASSWORD}\r\"
    expect \"sftp>\"
    send \"cd ${SUB_DIR##*/}\r\"
    expect \"sftp>\"
    send \"put ${SUB_DIR_FILE}\r\"
    expect \"sftp>\"
    send \"bye\r\"
    expect \"#\"
  "

  if [ -d $MOVING_FILES_LOCATION/${SUB_DIR##*/} ]
  then
      mv $SUB_DIR_FILE $MOVING_FILES_LOCATION/${SUB_DIR##*/}
  else
      mkdir $MOVING_FILES_LOCATION/${SUB_DIR##*/}
      mv $SUB_DIR_FILE $MOVING_FILES_LOCATION/${SUB_DIR##*/}
  fi

  done
done

rm $LOCK_FILE
log="Released lock file..."
printToLog
