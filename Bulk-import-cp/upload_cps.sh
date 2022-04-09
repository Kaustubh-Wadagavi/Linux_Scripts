#!/bin/bash

FILE=$1
USERNAME=admin
PASSWORD="Login@123"
DOMAIN_NAME="openspecimen"
URL="http://localhost:8080/openspecimen/rest/ng"
OBJECT_TYPE=cp
IMPORT_TYPE=CREATE
DATE_FORMAT=mm-dd-yyyy
TIME_FORMAT=HH:mm:ss

checkJobStatusAndDownloadReport(){
   if [ ! -z $TOKEN ] || [ ! -z $JOB_ID ];then
      RUNNING_JOB_STATUS=$(curl -H "X-OS-API-TOKEN: $TOKEN" -X GET "$URL/import-jobs/$JOB_ID")
      JOB_STATUS=$(echo $RUNNING_JOB_STATUS | grep -o '"status":"[^"]*' | grep -o '[^"]*$')
   else
      echo "JOB is not created. Please check what's went wrong."
      exit 0;
   fi

   if [ "$JOB_STATUS" = "FAILED" ];then
      curl -H "X-OS-API-TOKEN: $TOKEN" -X GET "$URL/import-jobs/$JOB_ID/output" >> failed_report_$JOB_ID.csv
      echo "The Import Job is failed. Downloaded the resport to: failed_report_$JOB_ID.csv"
   elif [ "$JOB_STATUS" = "COMPLETED" ];then
      curl -H "X-OS-API-TOKEN: $TOKEN" -X GET "$URL/import-jobs/$JOB_ID/output" >> success_report_$JOB_ID.csv
      echo "The import job is successfully completed saved in: success_report_$JOB_ID.csv"
   elif [ "$JOB_STATUS" = "IN_PROGRESS" ];then
      echo "The import job is running. Please wait....."
      sleep 5
      checkJobStatusAndDownloadReport
   fi

}

createAndRunTheImportJob(){   
   if [ ! -z $TOKEN ] || [ ! -z $FILE_ID ] ; then	
      IMPORT_JOB_DETAILS=$(curl -H "X-OS-API-TOKEN: $TOKEN" -X POST -H "Content-Type: application/json" -d '{"objectType":"'"$OBJECT_TYPE"'","importType":"'"$IMPORT_TYPE"'","inputFileId":"'"$FILE_ID"'","dateFormat":"'"$DATE_FORMAT"'","timeFormat":"'"$TIME_FORMAT"'"}' "$URL/import-jobs")
      IMPORT_JOB_ID=$(echo $IMPORT_JOB_DETAILS | tr , '\n' | grep id | awk -F ':' '{print $2}')
      JOB_ID=$(echo $IMPORT_JOB_ID | tr -d -c 0-9)
      echo $JOB_ID
   else
      echo "The Input file is not accepted by Server. Please send CSV file."
      exit 0;
   fi

}

getFileId(){
   if [ ! -z $TOKEN ]; then
      FILE_ID_DETAILS=$(curl -H "X-OS-API-TOKEN: $TOKEN" -X POST --form "file=@$FILE" "$URL/import-jobs/input-file")
      FILE_ID=$(echo $FILE_ID_DETAILS | grep -o '"fileId":"[^"]*' | grep -o '[^"]*$')
   else 
      echo "Authentication is not done. Please enter correct username and password."
      exit 0;
   fi

}

startSessions(){
   API_TOKEN=$(curl -u $USERNAME:$PASSWORD -X POST -H "Content-Type: application/json" -d '{"loginName":"'"$USERNAME"'","password":"'"$PASSWORD"'","domainName":"'"$DOMAIN_NAME"'"}' "$URL/sessions")
   TOKEN=$(echo $API_TOKEN | grep -o '"token":"[^"]*' | grep -o '[^"]*$')
    
}

if [[ $FILE == *.csv ]] 
then
   startSessions
   getFileId
   createAndRunTheImportJob
   checkJobStatusAndDownloadReport
else
   echo "Usage ./upload_cps.sh <fileName>.csv"
   echo "Please give input CSV file only."
   exit 0;
fi
