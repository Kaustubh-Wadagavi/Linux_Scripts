#! /bin/bash

LOCK_FILE=/tmp/print_lock.txt 

if [ -e $LOCK_FILE ] && kill -0 `cat $LOCK_FILE`; then
  exit                                 
fi

trap "rm -f $LOCK_FILE; exit" INT TERM EXIT

echo $$ > $LOCK_FILE

for sub_dir in `ls -d /usr/local/openspecimen/data/print-labels/*`
do
  for file in `ls -tr $sub_dir/*`        
  do
   sudo scp -i /home/krishagni/Desktop/sftp-scripts/jenkins-private $file jenkins@build.openspecimen.org:/home/jenkins/test
    if [ $? -ne 0 ]; then
      echo "Error Occured"  
    else
      echo "success"            
    fi
  done
done

rm $LOCK_FILE
