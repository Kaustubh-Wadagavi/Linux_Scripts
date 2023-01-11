#!/bin/bash

configFile=$1

getCustomerId() {
  c=0
  readarray -t customers < <(awk -F "," '{print $5}' $allIssues | awk 'NR!=1 {print}' | sort -u)
  customersCount=${#customers[@]}

  while [ $c -lt $customersCount ]
  do
    getCustomer=${customers[$c]}
    customerName=$(sed -e 's/^"//' -e 's/"$//' <<<"$getCustomer")  
    getCustomerDetails=$(curl -H "X-OS-API-TOKEN: $token" -H "Content-Type: application/json" -X POST -d '[{"expr":"'"Participant.ppid"'","values":["'"$customerName"'"]}]' "$url/rest/ng/lists/data?listName=participant-list-view&maxResults=101&objectId=1")
    customerId=`echo ${getCustomerDetails} | jq -r '.rows[0].hidden.cprId'`
    
    getFileName=$(echo $customerName | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')
    fileName=`ls -1 $outputDir | grep $getFileName`
    getFileId=$(curl -H "X-OS-API-TOKEN: $token" -X POST -F file=@$outputDir/$fileName "$url/rest/ng/form-files")
    fileId=`echo ${getFileId} | jq -r '.fileId'`
    
    updateCustomer=$(curl -H "X-OS-API-TOKEN: $token" -H "Content-Type: application/json" -X PUT -d '{"participant": {"ppid": "'"$customerName"'","extensionDetail":{"attrs":[{"name":"'"issues"'","value":{"filename":"'"$fileName"'","contentType": "'"text/csv"'","fileId": "'"$fileId"'"}}]}}}' "$url/rest/ng/collection-protocol-registrations/$customerId")
    let c++
  done

}

getToken() {
  session=$(curl -H "Content-Type: application/json" -X POST -d '{"loginName": "'"$loginName"'","password":"'"$password"'"}' "$url/rest/ng/sessions")
  token=`echo ${session} | jq -r '.token'`

}


sortClients() {
  sed -e s/deletethis//g -i $allIssuesCsv
  echo sorting clients
  i=0
  echo $i
  if [ -d "$outputDir" ]; then $(rm -Rf $outputDir); fi
  mkdir $outputDir
  readarray -t uniqueInstitutes < <(awk -F , '{print $5}' $allIssuesCsv | awk 'NR!=1 {print}' | sort -u)
  len=${#uniqueInstitutes[@]}
  
  while [ $i -lt $len ];
  do
    getInstitute=${uniqueInstitutes[$i]} 
    security=$(sed -e 's/^"//' -e 's/"$//' <<<"$getInstitute")
    createFileName=$(echo $security | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')
    file=$createFileName-$(date "+%Y-%m-%d").csv
    resultFile=$outputDir/$file
    csvgrep -c 5 -m "${security}" "${allIssuesCsv}" >> "${resultFile}"
    let i++
  done

}

saveAllIssues() {
  echo creating csv for all issues
  jq -r '["Ticket No.","Ticket Summary","Created On","Resolution Status","Security Level","Credits"], (.issues[] | [.key,.fields.summary,.fields.created,.fields.status.name,.fields.security.name,.fields.customfield_10500]) | @csv' ${issuesJson} >> ${tempAllIssues}
  awk '{if(! a[$1]){print; a[$1]++}}' ${tempAllIssues} > ${allIssues}

  echo '"Ticket No.","Ticket Summary","Created On","Resolution Status","Security Level","Credits"' >> ${allIssuesCsv}

  while IFS="," read -r ticket_no ticket_summary created_on resolution_status security_level credits
  do
    IFS=T read -r var_date var_time<<<"$created_on"
    string_date=$(sed -e 's/^"//' -e 's/"$//' <<<${var_date})
    created_date=\"${string_date}\"
    echo "$ticket_no","$ticket_summary","$created_date","$resolution_status","$security_level","$credits" >> ${allIssuesCsv}
  done < <(tail -n +2 $allIssues)

  rm $tempAllIssues
  rm $allIssues

}

getIssues() {
  echo 0 > ${tempFile}
  echo Creating issues Json
  getTotalNumberOfIssues=$(curl -X GET -H "Content-Type: application/json"  "https://openspecimen.atlassian.net/rest/api/3/search?jql=filter=18721" --user $userName:$token)
  numberOfIssues=`echo ${getTotalNumberOfIssues} | jq -r '.total'`

  getPaginationCount=$((numberOfIssues/100))
  paginationCount=$((getPaginationCount + 1))

  for(( counter=0; counter<=paginationCount; counter++ ))
  do
    maxResults=100
    echo $maxResults
    echo startAt: $startAt
    curl -X POST -H "Content-Type: application/json" -d '{"jql": "'"project = SUPPORT ORDER BY key ASC"'","startAt":"'"$startAt"'","maxResults":"'"$maxResults"'","fields":["key","summary","created","status","security","customfield_10500"]}' "https://openspecimen.atlassian.net/rest/api/2/search" --user $userName:$token >> ${issuesJson}
    startAt=$[$(cat $tempFile) + 100]
    echo $startAt > ${tempFile}
  done
  rm $tempFile

}

main() {
  if [ ! -f "$configFile" ]
  then
    echo "Please input the config file"
    exit 0;
  fi
  
  source $configFile
  getIssues
  saveAllIssues
  sortClients
  getToken
  getCustomerId

}

main;