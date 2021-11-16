#! /bin/bash

HOST=
USERNAME=
PASSWORD=
EXISTING_LOCATION=
LOG_FILE=

printToLog() {
    echo "$(date +%F-%T)-INFO-${log}"&>> $LOG_FILE 2>&1
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
  mv $SUB_DIR_FILE /usr/local/os-test/data/copied-print-labels/${SUB_DIR##*/}
  done
done

rm $LOCK_FILE
log="Released lock file..."
printToLog

