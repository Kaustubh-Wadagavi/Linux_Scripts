#!/bin/bash

URL=
TOMCAT_HOME=
OS_DATA=
SERVICE_NAME=
EMAIL_ID=
EMAIL_PASS=
CURRENT_TIME=
EMAIL_FILE=
RCPT_EMAIL_ID=
CLIENT_NAME_AND_ENVIRONMENT=
HEAP_DUMP_FILE=$TOMCAT_HOME/bin/$CURRENT_TIME.hprof


sendMail() {
curl --ssl-reqd --url 'smtps://smtp.gmail.com:465' -u $EMAIL_ID:$EMAIL_PASS --mail-from $EMAIL_ID --mail-rcpt $RCPT_EMAIL_ID -H "Subject: [ IMPORTANT ALERT ] : $CLIENT_NAME_AND_ENVIRONMENT" -F text="Hello Build Team, "$'\n'""$'\n'"The $CLIENT_NAME_AND_ENVIRONMENT restared. "$'\n'""$'\n'"The heap dump file location is: $HEAP_DUMP_FILE  "$'\n'""$'\n'"Regards, "$'\n'"auto-restart" -F attachment='@logs.zip'

}

restartServer() {
  $TOMCAT_HOME/bin/shutdown.sh -force
  $TOMCAT_HOME/bin/startup.sh

}

takeHeapDumpAndLogs() {
  PROCESS_ID=$(cat $TOMCAT_HOME/bin/pid.txt)
  if (( $(ps -ef | grep -v grep | grep $SERVICE_NAME | wc -l) > 0 ))
  then
      jmap -dump:live,format=b,file=$HEAP_DUMP_FILE $PROCESS_ID
      cp $TOMCAT_HOME/logs/catalina.out .
      cp $OS_DATA/logs/os.log .
      zip -r logs.zip catalina.out os.log
      rm -r catalina.out os.log
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
  for ((COUNT=0; $COUNT <= 10; COUNT++))
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
    takeHeapDumpAndLogs
  else
    echo "Someone Stopped OpenSpecimen...!"
    exit 0;
  fi

  PROCESS_STATUS=$?
  if [ $PROCESS_STATUS -eq 0 ]
  then
    restartServer
  fi
  
  sendMail
  rm -r logs.zip
  exit 0;

}

main;
