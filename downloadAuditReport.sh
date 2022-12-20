#!/bin/bash

userName=""                                                 # Username to call the REST APIs.
password=""                                                 # Password of the user.
url=""                                                      # Host Url.
startDate="2022-12-13"                                      # Start date 
endDate="2022-12-20"                                        # End Date
currentTime=$(date "+%Y%m%d_%H%M")

getAuditFile() {
  if [ "$file" = null ]
  then
    echo "You will recieve and email in a few minutes to download the audit report"
  else   
      curl -H "X-OS-API-TOKEN: $apiToken" -H "Content-Type: Content-Type: application/zip" -X GET "$url/rest/ng/audit/revisions-file?fileId=$file" > os_audit_revisions_$currentTime.zip
  fi

}

exportAudit() {
   fileId=$(curl -H "X-OS-API-TOKEN: $apiToken" -H "Content-Type: application/json" -X POST -d '{"includeModifiedProps": "'"true"'","startDate":"'"$startDate"'","endDate":"'"$endDate"'","reportTypes":["'"data"'","'"query_exim"'","'"api_calls"'","'"auth"'"]}' "$url/rest/ng/audit//export-revisions")
   file=`echo ${fileId} | jq -r '.fileId'`
   echo $file
}

getToken() {
  sessions=$(curl -H "Content-Type: application/json" -X POST -d '{"loginName": "'"$userName"'","password":"'"$password"'","domainName":"'"openspecimen"'"}' "$url/rest/ng/sessions")
  apiToken=`echo ${sessions} | jq -r '.token'`

}

getToken
exportAudit
getAuditFile
