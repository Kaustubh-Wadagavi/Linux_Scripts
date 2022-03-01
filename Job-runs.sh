#!/bin/bash

USERNAME=admin                                              # Username to call the REST APIs.
PASSWORD='Login@123'                                        # Password of the user.
JOB_ID=23                                                   # Id of the JOB.
URL="http://localhost:8080/openspecimen/"                   # Host Url.

getJobIdAndStatus() {
 JOB_DETAILS=$(curl -H "X-OS-API-TOKEN: $TOKEN" -H "Content-Type: application/json" --request GET "$URL/rest/ng/scheduled-jobs/$JOB_ID/runs")
 
 ID=`echo ${JOB_DETAILS} | jq -r '.[0].id'`
 STATUS=`echo ${JOB_DETAILS} | jq -r '.[0].status'`
 
 if [[ ! -z "$ID" ]] && [[ "$STATUS" = "SUCCEEDED" ]]
 then
    curl -H "X-OS-API-TOKEN: $TOKEN" -H "Content-Type: application/json" --request GET "$URL/$ID/result-file" >> scheduled_query_"$JOB_ID"_"$ID".csv 
    rm $JOB_DETAILS_FILE
    exit 0;
 elif [[ "$STATUS" -eq "IN_PROGRESS" ]]
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
  echo $TOKEN
}

getToken
executeJob
getJobIdAndStatus
