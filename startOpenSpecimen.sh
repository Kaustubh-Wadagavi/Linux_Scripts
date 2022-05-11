#!/bin/bash

URL=http://localhost:8080/openspecimen
COUNT=1
RETRY_COUNT=5
SERVICE_NAME=openspecimen
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
    CHECK_SERVICE_RUNNING_STATUS=$(ps -ef | grep -v grep | grep $SERVICE_NAME | wc -l)
    if [ $CHECK_SERVICE_RUNNING_STATUS -gt 0 ]
    then 
	echo $PASSWORD | sudo -S systemctl restart $SERVICE_NAME
	sleep 120
    elif [ $CHECK_SERVICE_RUNNING_STATUS -eq 0 ]
    then
	echo "Someone stopped the OpenSpecimen for maintainance...."
	exit 0
    fi
  fi
  invokeApi
  sleep 10
  ((COUNT=COUNT+1))
  echo $COUNT
  loadConfigProperties
}

loadConfigProperties
