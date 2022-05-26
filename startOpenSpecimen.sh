#!/bin/bash

URL=http://localhost:8080/openspecimen
TOMCAT_HOME=/usr/local/openspecimen/tomcat-as
SERVICE_NAME=openspecimen
PASSWORD='Krish!@3agni'
EMAIL_ID='do-not-reply@krishagni.com'
EMAIL_PASS='fmhrtiydtzqnfyke'
CURRENT_TIME=$(date "+%Y.%m.%d-%H.%M.%S")
EMAIL_FILE=$CURRENT_TIME.txt
RCPT_EMAIL_ID='build@krishagni.com'
CLIENT_NAME_AND_ENVIRONMENT="Kaustubh Local Instance"
HEAP_DUMP_FILE=$CURRENT_TIME.hprof

sendMail() {
  touch $EMAIL_FILE
  cat > $EMAIL_FILE << EOF
Subject: [ IMPORTANT ALERT ] : $CLIENT_NAME_AND_ENVIRONMENT
        
Hello Build Team,
 
   The server is restarted.

   Please check the server performance.

Regards,
Auto-Restart-Bot
EOF

  curl --ssl-reqd --url 'smtps://smtp.gmail.com:465' -u $EMAIL_ID:$EMAIL_PASS --mail-from $EMAIL_ID --mail-rcpt $RCPT_EMAIL_ID --upload-file $EMAIL_FILE

}

restartServer() {
  echo $PASSWORD | sudo -S systemctl start $SERVICE_NAME

}

takeHeapDumpAndKillPid() {
  PROCESS_ID=$(ps -ef | grep $SERVICE_NAME | grep -v grep | awk '{print $2}')
  if (( $(ps -ef | grep -v grep | grep $SERVICE_NAME | wc -l) > 0 ))
  then
      jmap -dump:live,format=b,file=$HEAP_DUMP_FILE $PROCESS_ID
      kill -9 $PROCESS_ID
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
  echo "Inside Invoke"
  wget --no-check-certificate -o applog  $URL/rest/ng/config-settings/app-props
  return $?;

}

main() {
  for ((COUNT=0; $COUNT <= 1; COUNT++))
  do
   echo "Inside For"
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
    takeHeapDumpAndKillPid
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
  exit 0;

}

main;
