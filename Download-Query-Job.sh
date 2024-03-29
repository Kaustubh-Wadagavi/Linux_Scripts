#!/bin/bash

USERNAME=admin                                              # Username to call the REST APIs.
PASSWORD='Login@123'                                        # Password of the user.
JOB_ID=23                                                   # Id of the JOB.
URL="http://localhost:8080/openspecimen/"                   # Host Url.

getCSV() {	
 JOB_DETAILS=$(curl -H "X-OS-API-TOKEN: $TOKEN" -H "Content-Type: application/json" --request GET "$URL/rest/ng/scheduled-jobs/$JOB_ID/runs")
 
 JOB_RUN_ID_AND_STATUS=`echo ${JOB_DETAILS} | jq -r '.[0].id,.[0].status'`
 
 JOB_RUN_ID=$(echo $JOB_RUN_ID_AND_STATUS | tr -d -c 0-9)
 
 JOB_RUN_STATUS=$(echo $JOB_RUN_ID_AND_STATUS | tr -d '0123456789 ')
 
 if [[ "$JOB_RUN_STATUS" = "SUCCEEDED" ]] && [[ $LAST_JOB_RUN_ID -lt $JOB_RUN_ID ]]
 then
    curl -H "X-OS-API-TOKEN: $TOKEN" -H "Content-Type: application/json" --request GET "$URL/rest/ng/scheduled-jobs/$JOB_ID/runs/$JOB_RUN_ID/result-file" >> scheduled_query_"$JOB_ID"_"$JOB_RUN_ID".csv
    exit 0;
 elif [[ "$JOB_RUN_STATUS" = "IN_PROGRESS" ]]
 then
    echo "Please wait the execution is running..."
    sleep 10;
    getCSV
 elif [[ $LAST_JOB_RUN_ID = $JOB_RUN_ID ]]
 then
    echo "The job is not executed please check..."
    exit 0;
 fi
}

executeJob() {
  curl -H "X-OS-API-TOKEN: $TOKEN" -H "Content-Type: application/json" --request POST --data '{ }' "$URL/rest/ng/scheduled-jobs/$JOB_ID/runs"
}

getLastExecutedJobRunID() {
  LAST_EXECUTION_DETAILS=$(curl -H "X-OS-API-TOKEN: $TOKEN" -H "Content-Type: application/json" --request GET "$URL/rest/ng/scheduled-jobs/$JOB_ID/runs")
  LAST_JOB_RUN_ID=`echo ${LAST_EXECUTION_DETAILS} | jq -r '.[0].id'`
}

getToken() {
  SESSIONS=$(curl -H "Content-Type: application/json" --request POST --data '{"loginName": "'"$USERNAME"'","password":"'"$PASSWORD"'","domainName":"'"openspecimen"'"}' "$URL/rest/ng/sessions")
    
  TOKEN=`echo ${SESSIONS} | jq -r '.token'`
}

getToken
getLastExecutedJobRunID
executeJob
getCSV
