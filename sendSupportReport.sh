#/bin/bash

configFile=$1

sendEmail() {
  currentMonth=$(date '+%B_%Y')
  tempFile=tempfile.txt
  echo -e "To: $emailId\nSubject: OpenSpecimen/$shortName: Monthly support log for $currentMonth\n\n \
  Hello $projectManager,\n\n \
  Below is the summary of the OpenSpecimen support activities.\n\n \
  Type of Support Package: $supportPackage\n \
  Start date of contract: $startDateOfContract\n \
  End date of contract: $endDateOfContract\n \
  Total credits: $totalCredits\n \
  Used credits: $usedCredits\n\n \
  Please find below details of support tickets:\n\n$(cat $reportFile)" > $tempFile

  curl --ssl-reqd --url 'smtps://smtp.gmail.com:465' -u $fromEmail:$emailPassword --mail-from $fromEmail -v --mail-rcpt $emailId --mail-rcpt $fromEmail --upload-file $tempFile
  rm $tempFile

}

getClientsEmailId() {
   #read email Ids and by reading file names   
   for reportFile in $destDir/*.csv
   do
     getFileName="$(basename $reportFile)"
     client=$(echo "$getFileName" | cut -d'-' -f1 | tr -d '[:space:]')
     getCustomerId=$(curl -H "X-OS-API-TOKEN: $os_token" -H "Content-Type: application/json" -X POST -d '[{"expr":"'"Participant.ppid"'","values":["'"$client"'"]}]' "$url/rest/ng/lists/data?listName=participant-list-view&maxResults=101&objectId=1")
     customerId=`echo ${getCustomerId} | jq -r '.rows[0].hidden.cprId'`
     getSupportDetails=$(curl -H "X-OS-API-TOKEN: $os_token" -H "Content-Type: application/json" -X GET "$url/rest/ng/collection-protocol-registrations/$customerId")
     emailId=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[3].displayValue'`
     shortName=`echo ${getSupportDetails} | jq -r '.ppid'`
     projectManager=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[2].displayValue'`
     contractType=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[4].displayValue'`
     startDateOfContract=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[8].displayValue'`
     endDateOfContract=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[9].displayValue'`
     totalCredits=250 #`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[8].displayValue'`
     usedCredits=100  #`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[8].displayValue'`
     sendEmail
   done

}

getToken() {
  session=$(curl -H "Content-Type: application/json" -X POST -d '{"loginName": "'"$loginName"'","password":"'"$password"'"}' "$url/rest/ng/sessions")
  os_token=`echo ${session} | jq -r '.token'`

}

copySendingFiles() {
   cp $sourceDir/*.csv $destDir
}

main() {
  if [ ! -f "$configFile" ]
  then
    echo insideif
    echo "Please input the config file"
    exit 0;
  fi
  
  source $configFile
 # copySendingFiles
  getToken
  getClientsEmailId

}

main;
