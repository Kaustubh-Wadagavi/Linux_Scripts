#!/bin/bash

URL=$1
now="$(date)"
COUNT=1
RETRY_COUNT=2
SERVICE_NAME=openspecimen
DUMP_FILE=/usr/local/openspecimen/heapDump.bin
PASSWORD='Krish!@3agni'

invokeApi() {
  wget -T 60 --no-check-certificate $URL/rest/ng/config-settings/app-props
  STATUS=$?
  if [ $STATUS -eq 0 ]
  then
    echo "App is running.."
    exit 0
  fi
}

loadConfigProperties() {
  if [ $COUNT -gt $RETRY_COUNT ]
  then
    PID=$(ps -ef | grep $SERVICE_NAME | grep -v grep | awk '{print $2}')
    echo $PASSWORD | sudo -S systemctl start $SERVICE_NAME
    #sendEmail
  fi
  invokeApi
  sleep 10
  ((COUNT=COUNT+1))
  echo $COUNT
  loadConfigProperties
}

if [[ -z $URL ]]
then
    echo "USAGE: ./startOpenSpecimen.sh <URL>"
    echo "Please send a URL in command line"
    exit 0
fi

loadConfigProperties
