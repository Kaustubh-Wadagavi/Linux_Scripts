#!/bin/bash

HOST=
USERNAME=
PASSWORD=
EXISTING_LOCATION=
LOG_FILE=
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

for SUB_DIR in $EXISTING_LOCATION/*/
do
  log="Processing directory:${SUB_DIR}"
  printToLog

  SUB_DIR="${SUB_DIR%/}"
  DIR="${SUB_DIR##*/}"

  log="Picked SUB DIR NAME:${DIR}"
  printToLog

  if [[ ${DIR} = *" "* ]]; then
     SUB_DIR=""
     SUB_DIR=$EXISTING_LOCATION/$DIR/
     cd "$SUB_DIR"
     log="Changing existing location:${SUB_DIR}"
     printToLog
   else
     cd "$EXISTING_LOCATION/$DIR"
     log="Changing Existing Location:$EXISTING_LOCATION/$DIR"
     printToLog
  fi

  for FILE in `ls -tr ./*`
  do
   log="Picked the file name:${FILE}"
   printToLog
   log="Connecting to SFTP..."
   printToLog

   expect -c "
    spawn sftp $USERNAME@$HOST
    expect \"password: \"
    send \"${PASSWORD}\r\"
    expect \"sftp>\"
    send \"cd '${DIR}'\r\"
    expect \"sftp>\"
    send \"put ${FILE}\r\"
    expect \"sftp>\"
    send \"bye\r\"
    expect \"#\"
  "

  if [ -d "$MOVING_FILES_LOCATION/${DIR}" ]
   then
      mv $FILE "$MOVING_FILES_LOCATION/${DIR}"
      log="Permenantly Moving the File...$FILE"
      printToLog
   else
      mkdir "$MOVING_FILES_LOCATION/${DIR}"
      log="Creating the directory:$MOVING_FILES_LOCATION/${DIR}"
      printToLog
      mv $FILE "$MOVING_FILES_LOCATION/${DIR}"
  fi
  done
done

rm $LOCK_FILE
log="Released lock file..."
printToLog
