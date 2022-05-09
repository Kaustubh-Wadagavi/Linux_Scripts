#!/bin/bash

URL=http://localhost:8080/openspecimen
COUNT=1
RETRY_COUNT=10
SERVICE_NAME=openspecimen
#DUMP_FILE=/usr/local/openspecimen/heapDump.hprof
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
