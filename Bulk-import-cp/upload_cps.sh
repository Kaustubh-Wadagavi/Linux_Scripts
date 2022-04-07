#!/bin/bash

FILE=$1
USERNAME="kaustubh"
PASSWORD="Login@123"
DOMAIN_NAME="openspecimen"
URL="https://test.openspecimen.org/rest/ng"
OBJECT_TYPE=cp
IMPORT_TYPE=CREATE
DATE_FORMAT=mm-dd-yyyy
TIME_FORMAT=HH:mm:ss

if [ ! -f $FILE ]; then
   echo "Usage ./upload_cps.sh <fileName>.csv" 
fi

checkJobStatusAndDownloadReport(){

   RUNNING_JOB_STATUS=$(curl -u $USERNAME:$PASSWORD -X GET "$URL/import-jobs/$JOB_ID")
   JOB_STATUS=$(echo $RUNNING_JOB_STATUS | grep -o '"status":"[^"]*' | grep -o '[^"]*$')

   if [ "$JOB_STATUS" = "FAILED" ];then
      echo "The Import Job is failed. Downloaded the resport to: failed_report_$JOB_ID.csv"
      curl -u $USERNAME:$PASSWORD -X GET "$URL/import-jobs/$JOB_ID/output" >> failed_report_$JOB_ID.csv
   elif [ "$JOB_STATUS" = "COMPLETED" ];then
      echo "The import job is successfully completed saved in: success_report_$JOB_ID.csv"
      curl -u $USERNAME:$PASSWORD -X GET "$URL/import-jobs/$JOB_ID/output" >> success_report_$JOB_ID.csv
   else
       echo "The import job is running. Please wait....."
       sleep 5
       checkJobStatusAndDownloadReport   
   fi

}

createAndRunTheImportJob(){
   
   IMPORT_JOB_DETAILS=$(curl -u $USERNAME:$PASSWORD -X POST -H "Content-Type: application/json" -d '{"objectType":"'"$OBJECT_TYPE"'","importType":"'"$IMPORT_TYPE"'","inputFileId":"'"$FILE_ID"'","dateFormat":"'"$DATE_FORMAT"'","timeFormat":"'"$TIME_FORMAT"'"}' "$URL/import-jobs")
   
   IMPORT_JOB_ID=$(echo $IMPORT_JOB_DETAILS | tr , '\n' | grep id | awk -F ':' '{print $2}')
   JOB_ID=$(echo $IMPORT_JOB_ID | tr -d -c 0-9)
}

getFileId(){
    FILE_ID_DETAILS=$(curl -u $USERNAME:$PASSWORD -X POST --form "file=@$FILE" "$URL/import-jobs/input-file")
    FILE_ID=$(echo $FILE_ID_DETAILS | grep -o '"fileId":"[^"]*' | grep -o '[^"]*$')
}


getFileId
createAndRunTheImportJob
checkJobStatusAndDownloadReport
