#!/bin/bash

userName=                                                                       #Jira Username
token=                                                                          #Jira Token to call APIs
url=                                                                            #Jira URL
currentTime=$(date "+%Y_%m_%d_%H%M%S")
allIssues=jira-support-issues-$currentTime.csv
issuesJson=issues-$currentTime.json
outputDir=output
loginName=                                                                      #OpenSpecimen Login Name
password=                                                                       #OpenSpecimen Password
url=                                                                            #OpenSpecimen URL

updateCustomer() {
  c=0
  readarray -t customers < <(awk -F "," '{print $4}' $allIssues | awk 'NR!=1 {print}' | sort -u)
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
  i=0
  if [ -d "$outputDir" ]; then rm -Rf $outputDir; fi
  mkdir output
  readarray -t uniqueInstitutes < <(awk -F "," '{print $4}' $allIssues | awk 'NR!=1 {print}' | sort -u)
  len=${#uniqueInstitutes[@]}
  
  while [ $i -lt $len ];
  do
    getInstitute=${uniqueInstitutes[$i]} 
    security=$(sed -e 's/^"//' -e 's/"$//' <<<"$getInstitute")
    createFileName=$(echo $security | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')
    file=$createFileName-$(date "+%Y-%m-%d").csv
    resultFile=$outputDir/$file
    csvgrep -c 4 -m "${security}" "${allIssues}" >> "${resultFile}"
    soffice --headless --convert-to pdf:calc_pdf_Export $resultFile --outdir $outputDir
    rm -r $resultFile
    let i++
  done

}

saveAllIssues() {
 echo creating csv for all issues
 totalIssues=$(cat $issuesJson | jq '.total')
 echo '"Ticket No.","Ticket Summary","Resolution Status","Security Level","Credits"' >> $allIssues
  for (( c=0; c<$totalIssues; c++ ))
  do
    key=$(cat $issuesJson | jq '.issues['$c'].key')
    summary=$(cat $issuesJson | jq '.issues['$c'].fields.summary')
    issueStatus=$(cat $issuesJson | jq '.issues['$c'].fields.status.name')
    security=$(cat $issuesJson | jq '.issues['$c'].fields.security.name')
    credits=$(cat $issuesJson | jq '.issues['$c'].fields.customfield_10500')
    echo "$key","$summary","$issueStatus","$security","$credits" >> $allIssues
  done

}

getIssues() {
  echo Creating issues Json
  curl -X GET -H "Content-Type: application/json"  "https://openspecimen.atlassian.net/rest/api/3/search?jql=filter=18721" --user $userName:$token > $issuesJson

}

getIssues
saveAllIssues
sortClients
getToken
updateCustomer
