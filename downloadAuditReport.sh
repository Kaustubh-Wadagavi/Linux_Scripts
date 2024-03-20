#!/bin/bash

userName=""                                                                                      # Username to call the REST APIs.
password=""                                                                                      # Password of the user.
url="http://localhost:8080/openspecimen"                                                         # Host Url.
startDate=$(date -d "$(date -d "$(date +%Y-%m-15) -1 month")" "+%Y-%m-01")                       # picks the last months start date
endDate=$(date -d "$(date +%Y-%m-01) -1 day" "+%Y-%m-%d")                                        # picks the last months end date
currentTime=$(date "+%Y%m%d_%H%M")

getAuditFile() {
  if [ "$file" = null ]
  then
    echo "You will recieve an email with download link in a few minutes to download the audit report"
  else   
      curl -H "X-OS-API-TOKEN: $apiToken" -H "Content-Type: Content-Type: application/zip" -X GET "$url/rest/ng/audit/revisions-file?fileId=$file" > os_audit_revisions_$currentTime.zip
  fi

}

exportAudit() {
   startDateFormatted=$(date -d "$startDate" "+%Y-%m-%d")
   endDateFormatted=$(date -d "$endDate" "+%Y-%m-%d")
   fileId=$(curl -H "X-OS-API-TOKEN: $apiToken" -H "Content-Type: application/json" -X POST -d '{"includeModifiedProps": "'"true"'","startDate":"'"$startDateFormatted"'","endDate":"'"$endDateFormatted"'","reportTypes":["'"data"'","'"query_exim"'","'"api_calls"'","'"auth"'"]}' "$url/rest/ng/audit//export-revisions")
   file=`echo ${fileId} | jq -r '.fileId'`

}

getToken() {
  sessions=$(curl -H "Content-Type: application/json" -X POST -d '{"loginName": "'"$userName"'","password":"'"$password"'","domainName":"'"openspecimen"'"}' "$url/rest/ng/sessions")
  apiToken=`echo ${sessions} | jq -r '.token'`
  
  if [ -z "$apiToken" ]; then
    echo "Please enter valid credentials.."
    exit 1
  fi

}

main () {
 
  getToken
  exportAudit
  getAuditFile
}

main;
