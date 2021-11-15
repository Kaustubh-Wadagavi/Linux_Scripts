#! /bin/bash

HOST=
USERNAME=
PASSWORD=
TARGET_LOCATION=study02/
EXISTING_LOCATION=/usr/local/os-test/data/print-labels/


LOCK_FILE=/tmp/print_lock.txt
log="locking file ...."

if [ -e $LOCK_FILE ] && kill -0 `cat $LOCK_FILE`; then
  exit
fi

trap "rm -f $LOCK_FILE; exit" INT TERM EXIT

for SUB_DIR in `ls -d $EXISTING_LOCATION/*`
do
  for SUB_DIR_FILE in `ls -tr $SUB_DIR/*`
  do
   echo $SUB_DIR_FILE
    expect -c "
    spawn sftp UTSHB@129.106.148.161
    expect \"password: \"
    send \"${PASSWORD}\r\"
    expect \"sftp>\"
    send \"put $SUB_DIR/*\r\"
    expect \"sftp>\"
    send \"bye\r\"
    expect \"#\"
  "
  done
done

rm $LOCK_FILE

