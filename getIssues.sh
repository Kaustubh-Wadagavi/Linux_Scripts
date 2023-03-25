#!/bin/bash

configFile=$1

uploadFileInDarpan() {
  echo Upload file in darpan
  c=0
  readarray -t customers < <(awk -F "," '{print $3}' $allIssuesCsv | awk 'NR!=1 {print}' | sort -u)
  customersCount=${#customers[@]}
  echo ===========================================
  echo $customersCount
  echo ===========================================
  while [ $c -lt $customersCount ]
  do
    getCustomer=${customers[$c]}
    customerName=$(sed -e 's/^"//' -e 's/"$//' <<<"$getCustomer")
    getCustomerDetails=$(curl -H "X-OS-API-TOKEN: $os_token" -H "Content-Type: application/json" -X POST -d '[{"expr":"'"Participant.ppid"'","values":["'"$customerName"'"]}]' "$url/rest/ng/lists/data?listName=participant-list-view&maxResults=101&objectId=1")
    customerId=`echo ${getCustomerDetails} | jq -r '.rows[0].hidden.cprId'`
    finalOutput=/home/krishagni/Desktop/jira-darpan-integration/finalOutput    
    getFileName=$(echo $customerName | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')
    fileName=`ls -1 $finalOutput | grep "\b$getFileName\b"`   #$getFileName`
    echo =======================================================================
    echo file: $fileName client: $customerName
    echo ========================================================================
    getFileId=$(curl -H "X-OS-API-TOKEN: $os_token" -X POST -F file=@$finalOutput/$fileName "$url/rest/ng/form-files")
    fileId=`echo ${getFileId} | jq -r '.fileId'`
    
    updateCustomer=$(curl -H "X-OS-API-TOKEN: $os_token" -H "Content-Type: application/json" -X PUT -d '{"participant": {"ppid": "'"$customerName"'","extensionDetail":{"attrs":[{"name":"'"issues"'","value":{"filename":"'"$fileName"'","contentType": "'"text/csv"'","fileId": "'"$fileId"'"}}]}}}' "$url/rest/ng/collection-protocol-registrations/$customerId")
    let c++
  done

}

createTotalCreditsFile() {
  if [ -d "$finalOutput" ]; then $(rm -Rf $finalOutput); fi
  k=0
  mkdir $finalOutput
  readarray -t institutes < <(awk -F , '{print $3}' ${allIssuesCsv} | awk 'NR!=1 {print}' | sort -u)
  instituteCount=${#institutes[@]}

 while [ $k -lt $instituteCount ];
 do
    getInstiName=${institutes[$k]}
    client=$(sed -e 's/^"//' -e 's/"$//' <<<"$getInstiName")
    getCustomerId=$(curl -H "X-OS-API-TOKEN: $os_token" -H "Content-Type: application/json" -X POST -d '[{"expr":"'"Participant.ppid"'","values":["'"$client"'"]}]' "$url/rest/ng/lists/data?listName=participant-list-view&maxResults=101&objectId=1")
    getJsonLength=`echo $getCustomerId | jq '.rows | length'`
    echo getJsonLength:$getJsonLength
    if [[ $getJsonLength -gt 0 ]]
    then
      #Get Support Date
      customerId=`echo ${getCustomerId} | jq -r '.rows[0].hidden.cprId'`
      getSupportDetails=$(curl -H "X-OS-API-TOKEN: $os_token" -H "Content-Type: application/json" -X GET "$url/rest/ng/collection-protocol-registrations/$customerId")
      startDateOfSupport=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[8].displayValue'`
      read date mon year <<< $startDateOfSupport
      supportStartDate=$(date -d "$date $mon $year" "+%Y-%m-%d")
      echo =============================================================================
      echo "$supportStartDate"
      echo =============================================================================
      #Export Issues from Support Start date
      getSortedFile=$(echo $client | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')
      sortedFileName=`ls -1 $outputDir | grep $getSortedFile`
      finalFile=$getSortedFile-$(date "+%Y-%m-%d").csv
      finalResultFile=$finalOutput/$finalFile
      awk -F , '$2>="'"$supportStartDate"'" { print }' ${outputDir}/${sortedFileName}>>${finalResultFile}
      let k++
    else
     let k++
    fi
 done
  
}

getToken() {
  session=$(curl -H "Content-Type: application/json" -X POST -d '{"loginName": "'"$loginName"'","password":"'"$password"'"}' "$url/rest/ng/sessions")
  os_token=`echo ${session} | jq -r '.token'`
  echo $os_token

}

sortClients() {
  echo sorting clients
  i=0
  echo $i
  if [ -d "$outputDir" ]; then $(rm -Rf $outputDir); fi
  mkdir $outputDir
  readarray -t institutesList < <(awk -F , '{print $3}' $allIssuesCsv | awk 'NR!=1 {print}' | sort -u)
  len=${#institutesList[@]}
  
  while [ $i -lt $len ];
  do
    getInstitute=${institutesList[$i]} 
    security=$(sed -e 's/^"//' -e 's/"$//' <<<"$getInstitute")
    createFileName=$(echo $security | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')
    file=$createFileName-$(date "+%Y-%m-%d").csv
    resultFile=$outputDir/$file
    csvgrep -c 3 -r "\b${security}\b" "${allIssuesCsv}" >> "${resultFile}"
    let i++
  done

}

saveAllIssues() {
  echo creating csv for all issues
  jq -r '["Ticket No.","Created On","Security Level","Ticket Summary","Resolution Status","Credits"], (.issues[] | [.key,.fields.created,.fields.security.name,.fields.summary,.fields.status.name,.fields.customfield_10500]) | @csv' ${issuesJson} >> ${tempAllIssues}
  awk '{if(! a[$1]){print; a[$1]++}}' ${tempAllIssues} > ${allIssues}

  echo '"Ticket No.","Created On","Security Level","Ticket Summary","Resolution Status","Credits"' >> ${allIssuesCsv}

  while IFS="," read -r ticket_no created_on security_level ticket_summary resolution_status credits
  do
    IFS=T read -r var_date var_time<<<"$created_on"
    string_date=$(sed -e 's/^"//' -e 's/"$//' <<<${var_date})
    created_date=\"${string_date}\"
    echo "$ticket_no","$created_date","$security_level","$ticket_summary","$resolution_status","$credits" >> ${allIssuesCsv}
  done < <(tail -n +2 $allIssues)

  rm $tempAllIssues
  rm $allIssues

}

getIssues() {
  echo 0 > ${tempFile}
  echo Creating issues Json
  getTotalNumberOfIssues=$(curl -X GET -H "Content-Type: application/json"  "$jiraUrl/rest/api/3/search?jql=filter=18721" --user $userName:$token)
  numberOfIssues=`echo ${getTotalNumberOfIssues} | jq -r '.total'`

  getPaginationCount=$((numberOfIssues/100))
  paginationCount=$((getPaginationCount + 1))

  for(( counter=0; counter<=paginationCount; counter++ ))
  do
    maxResults=100
    echo $maxResults
    echo startAt: $startAt
    curl -X POST -H "Content-Type: application/json" -d '{"jql": "'"project = SUPPORT ORDER BY key ASC"'","startAt":"'"$startAt"'","maxResults":"'"$maxResults"'","fields":["key","summary","created","status","security","customfield_10500"]}' "$jiraUrl/rest/api/2/search" --user $userName:$token >> ${issuesJson}
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
  createTotalCreditsFile
  uploadFileInDarpan

}

main;
