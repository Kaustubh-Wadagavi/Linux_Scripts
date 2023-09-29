#!/bin/bash

checkJobStatusAndDownloadReport() {
   if [ ! -z $TOKEN ];then
      RUNNING_JOB_STATUS=$(curl -H "X-OS-API-TOKEN: $TOKEN" -X GET "$URL/rest/ng/import-jobs/")
      echo $RUNNING_JOB_STATUS
      CURRENT_RUNNING_JOB=$(echo $RUNNING_JOB_STATUS | jq 'max_by(.id)')
      JOB_ID=$(echo $CURRENT_RUNNING_JOB | jq -r '.id')
      JOB_STATUS=$(echo $CURRENT_RUNNING_JOB | jq -r '.status')
   else
      echo "JOB is not created. Please check what's went wrong."
      exit 0;
   fi

   if [ "$JOB_STATUS" = "FAILED" ];then
      curl -H "X-OS-API-TOKEN: $TOKEN" -X GET "$URL/rest/ng/import-jobs/$JOB_ID/output" >> failed_report_$JOB_ID.csv
      echo "The Import Job is failed. Downloaded the resport to: failed_report_$JOB_ID.csv"
   elif [ "$JOB_STATUS" = "COMPLETED" ];then
      curl -H "X-OS-API-TOKEN: $TOKEN" -X GET "$URL/rest/ng/import-jobs/$JOB_ID/output" >> success_report_$JOB_ID.csv
      echo "The import job is successfully completed saved in: success_report_$JOB_ID.csv"
   elif [ "$JOB_STATUS" = "IN_PROGRESS" ] || [ "$JOB_STATUS" = "QUEUED" ];then
      echo "The import job is running. Please wait....."
      sleep 5
      checkJobStatusAndDownloadReport
   fi

}

createAndRunTheImportJob() {   
   if [ ! -z $TOKEN ] || [ ! -z $FILE_ID ] ; then	
      IMPORT_JOB_DETAILS=$(curl -H "X-OS-API-TOKEN: $TOKEN" -X POST -H "Content-Type: application/json" -d '{
  													       "objectType": "'"$OBJECT_TYPE"'",
  													       "importType": "'"$IMPORT_TYPE"'",
  													       "inputFileId": "'"$FILE_ID"'",
  													       "dateFormat": "'"$DATE_FORMAT"'",
                                                                                      			       "timeFormat": "'"$TIME_FORMAT"'",
                                                                                                               "objectParams": {
                                                                                                                   "entityType": "'"$ENTITY_TYPE"'",
                                                                                                                   "formName": "'"$FORM_NAME"'",
                                                                                                                   "cpId": -1
                                                                                                                },
                                                                                                                "atomic": true
                                                                                                             }' "$URL/rest/ng/import-jobs")
   else
      echo "The Input file is not accepted by Server. Please send CSV file."
      exit 0;
   fi

}

getFileId() {
   if [ ! -z $TOKEN ]; then
      FILE_ID_DETAILS=$(curl -H "X-OS-API-TOKEN: $TOKEN" -X POST --form "file=@$FILE" "$URL/rest/ng/import-jobs/input-file")
      FILE_ID=$(echo $FILE_ID_DETAILS | jq -r '.fileId')
   else 
      echo "Authentication is not done. Please enter correct username and password."
      exit 0;
   fi

}

startSessions() {
   API_TOKEN=$(curl -u $USERNAME:$PASSWORD -X POST -H "Content-Type: application/json" -d '{"loginName":"'"$USERNAME"'","password":"'"$PASSWORD"'"}' "$URL/rest/ng/sessions")
   echo $API_TOKEN
   TOKEN=$(echo $API_TOKEN | jq -r '.token')
   echo $TOKEN    

}

main() {
  source "$CONFIG_FILE"
  if [[ "$FILE" != *.csv ]]; then
    echo "Error: The FILE parameter must end with '.csv'."
  fi

  startSessions
  getFileId
  createAndRunTheImportJob
  checkJobStatusAndDownloadReport

}

if [ $# -ne 1 ]; then
  echo "Usage: ./upload_cp_data.sh <config file>"
  echo "Please provide a config file with command line parameters."
  exit 1;

fi

CONFIG_FILE=$1
if [ ! -e "$CONFIG_FILE" ]; then
  echo "Error: Configuration file '$CONFIG_FILE' not found."
  exit 1;

fi

main;
