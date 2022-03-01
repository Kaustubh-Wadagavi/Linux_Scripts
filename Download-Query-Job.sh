#!/bin/bash

USERNAME=admin                                              # Username to call the REST APIs.
PASSWORD='Login@123'                                        # Password of the user.
JOB_ID=23                                                   # Id of the JOB.
URL="http://localhost:8080/openspecimen/"                   # Host Url.

getCSV() {
 JOB_DETAILS=$(curl -H "X-OS-API-TOKEN: $TOKEN" -H "Content-Type: application/json" --request GET "$URL/rest/ng/scheduled-jobs/$JOB_ID/runs")
 
 JOB_RUN_ID=`echo ${JOB_DETAILS} | jq -r '.[0].id'`
 JOB_RUN_STATUS=`echo ${JOB_DETAILS} | jq -r '.[0].status'`
 
 if [[ ! -z "$JOB_RUN_ID" ]] && [[ "$JOB_RUN_STATUS" = "SUCCEEDED" ]]
 then
    curl -H "X-OS-API-TOKEN: $TOKEN" -H "Content-Type: application/json" --request GET "$URL/rest/ng/scheduled-jobs/$JOB_ID/runs/$JOB_RUN_ID/result-file" >> scheduled_query_"$JOB_ID"_"$JOB_RUN_ID".csv
    exit 0;
 elif [[ "$JOB_RUN_STATUS" -eq "IN_PROGRESS" ]]
 then
    echo "Please wait the execution is running..."
    sleep 10;
    getJobIdAndStatus
 fi
}

executeJob() {
  curl -H "X-OS-API-TOKEN: $TOKEN" -H "Content-Type: application/json" --request POST --data '{ }' "$URL/rest/ng/scheduled-jobs/$JOB_ID/runs"
}

getToken() {
  SESSIONS=$(curl -H "Content-Type: application/json" --request POST --data '{"loginName": "'"$USERNAME"'","password":"'"$PASSWORD"'","domainName":"'"openspecimen"'"}' "$URL/rest/ng/sessions")
    
  TOKEN=`echo ${SESSIONS} | jq -r '.token'`
}

getToken
executeJob
getCSV
