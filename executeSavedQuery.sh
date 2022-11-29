#!/bin/bash

USERNAME=$1                                              # Username to call the REST APIs.
PASSWORD=$2                                              # Password of the user.
URL=$3                                              # Id of the JOB.
QUERY_ID=$4                                                   # Host Url.

executeQuery() {
  curl -H "X-OS-API-TOKEN: $TOKEN" -H "Content-Type: application/json" --request POST --data '{ }' "$URL/rest/ng/query/$QUERY_ID"
}


startSession() {
  SESSIONS=$(curl -H "Content-Type: application/json" --request POST --data '{"loginName": "'"$USERNAME"'","password":"'"$PASSWORD"'","domainName":"'"openspecimen"'"}' "$URL/rest/ng/sessions")
    
  TOKEN=`echo ${SESSIONS} | jq -r '.token'`
}

checkInputs() {
  if [ -z $USERNAME ] && [ -z $USERNAME ] && [ -z $USERNAME ] && [ -z $USERNAME ]
  then
    echo "Please give command line parameters to while running the script."
    echo "Usage: ./executeSavedQuery.sh <USERNAME> <PASSWORD> <SERVER_URL> <QUERY_ID"
    exit 1;
  fi
}
   
checkInputs
startSession
executeQuery
