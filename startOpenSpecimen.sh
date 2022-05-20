#!/bin/bash

URL=https://build.openspecimen.org/openspecimen
TOMCAT_HOME=/usr/local/openspecimen/tomcat-as
SERVICE_NAME=openspecimen
PASSWORD='Krish!@3agni'

restartServer() {
  echo $PASSWORD | sudo -S systemctl start $SERVICE_NAME

}

checkProcess() {
  if (( $(ps -ef | grep -v grep | grep $SERVICE_NAME | wc -l) > 0 ))
  then
      kill -9 $(ps -ef | grep $SERVICE_NAME | grep -v grep | awk '{print $2}')
      return 0;
  else
      return 1;
  fi

}

checkPid() {
  if [ -f "$TOMCAT_HOME/bin/pid.txt" ]
  then 
      return 0;
  else 
      return 1;
  fi 

}

invokeApi() {
  wget --no-check-certificate -o applog  $URL/rest/ng/config-settings/app-props
  return $?;

}

main() {
  for ((COUNT=0; $COUNT <= 5; COUNT++))
  do
   invokeApi
    STATUS=$?
    if [ $STATUS -eq 0 ]
    then
      echo "App is running..."
      exit 0;
    fi
    sleep 10;
  done

  checkPid
  PID_EXISTS=$?
  if [ $PID_EXISTS -eq 0 ]
  then
    checkProcess
  else
    echo "Someone Stopped OpenSpecimen...!"
    exit 0;
  fi

  PROCESS_STATUS=$?
  if [ $processStatus -eq 0 ]
  then
    restartServer
    exit 0;
  fi

}

main;
