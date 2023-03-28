#!/bin/bash

configFile=$1

updateCredits() {
   for reportFile in $destDir/*.csv
   do
     echo filename: $reportFile
     totalCredits=$(awk -F',' 'NR>1 && $4 ~ /^[0-9]+$/ { sum+=$4 } END { print sum }' $reportFile)
     echo ================================================================
     echo $totalCredits
     echo ===============================================================
     getFileName="$(basename $reportFile)"
     client=$(echo "$getFileName" | cut -d'-' -f1 | tr -d '[:space:]')
     getCustomerId=$(curl -H "X-OS-API-TOKEN: $os_token" -H "Content-Type: application/json" -X POST -d '[{"expr":"'"Participant.ppid"'","values":["'"$client"'"]}]' "$url/rest/ng/lists/data?listName=participant-list-view&maxResults=101&objectId=1")
     customerId=`echo ${getCustomerId} | jq -r '.rows[0].hidden.cprId'`
     curl -X PUT -H "X-OS-API-TOKEN: $os_token" -H "Content-Type: application/json" -X PUT -d '{"participant":{"extensionDetail":{"formCaption":"Krishagni_clients","attrs":[{"name":"used_credits","value":"'"$totalCredits"'"}]}}}' "$url/rest/ng/collection-protocol-registrations/$customerId"
  done  

}

getToken() {
  session=$(curl -H "Content-Type: application/json" -X POST -d '{"loginName": "'"$loginName"'","password":"'"$password"'"}' "$url/rest/ng/sessions")
  os_token=`echo ${session} | jq -r '.token'`

}

copyCreditsFile() {
   if [ -d $destDir ]; then rm -r $destDir; fi
   mkdir -p $destDir
   cp $sourceDir/*.csv $destDir/

}

main() {
  if [ ! -f "$configFile" ]
  then
    echo "Please input the config file"
    exit 0;
  fi

  source $configFile
  copyCreditsFile
  getToken
  updateCredits

}

main;

