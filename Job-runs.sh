#!/bin/bash

USERNAME=                                          # Username to call the REST APIs.
PASSWORD=                                          # Password of the user.
JOB_ID=                                            # Id of the JOB.
URL=                                               # URL to call /rest/ng/scheduled-jobs/$JOB_ID/runs 
JOB_DETAILS_FILE=                                  # Absolute path to execution details storing .json file 
RESULT_FILE=                                       # Absolute path to download the file. e.g. /home/scheduled_query_$JOB_ID

getJobIdAndStatus(){
 # Calling get method to get the execution details of the Job.	
 curl --user $USERNAME:$PASSWORD --header "Content-Type: application/json" --request GET $URL > $JOB_DETAILS_FILE
 
 # Getting id of the latest execution id and status
 ID=( $(jq -r '.[0].id' $JOB_DETAILS_FILE) )
 STATUS=($(jq -r '.[0].status' $JOB_DETAILS_FILE))
 
 # Downloading the file
 if [[ ! -z "$ID" ]] && [[ "$STATUS" = "SUCCEEDED" ]]
 then
    curl --user $USERNAME:$PASSWORD --header "Content-Type: application/json" --request GET "$URL/$ID/result-file" >> $RESULT_FILE"_$ID".csv 
    rm $JOB_DETAILS_FILE
    exit 0;
 elif [[ "$STATUS" -eq "IN_PROGRESS" ]]
 then
    echo "Please wait the execution is running..."
    sleep 10;
    getJobIdAndStatus
 fi
}

# Step to execute the job.
executeJob(){
    curl --user $USERNAME:$PASSWORD --header "Content-Type: application/json" --request POST --data '{ }' $URL
}

executeJob
getJobIdAndStatus
