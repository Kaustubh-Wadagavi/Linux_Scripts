#/bin/bash

configFile=$1

sendEmail() {
  currentMonth=$(date '+%B_%Y')
  tempFile=tempfile.txt
  toEmail="kaustubh@krishagni.com, kaustubhwadagavi@gmail.com" # Add multiple email addresses separated by comma
  if [[ $toEmail == *,* ]]; then
   mail1=$(echo $toEmail | cut -d ',' -f1)
   mail2=$(echo $toEmail | cut -d ',' -f2)
 else
   var1=$toEmail
 fi
  echo -e "To: $mail1, $mail2\ncc: $ccEmail1, $ccEmail2\nSubject: OpenSpecimen/$shortName: Monthly support log for $currentMonth\n\n \
  Hello $projectManager,\n\n \
  Below is the summary of the OpenSpecimen support activities.\n\n \
  Type of Support Package: $contractType\n \
  Start date of contract: $startDateOfContract\n \
  End date of contract: $endDateOfContract\n \
  Total credits: $totalCredits\n \
  Used credits: $usedCredits\n\n \
  Please find below details of support tickets: \
  $(echo "$announcement" | sed -e 's/<[^>]*>//g' -e 's/^\s*//' -e 's/<br\s*\/>/\n/g')\n\n$(cat $reportFile)" > $tempFile

  curl --ssl-reqd --url 'smtps://smtp.gmail.com:465' -u $fromEmail:$emailPassword --mail-from $fromEmail -v --mail-rcpt $mail1 --mail-rcpt $mail2 --upload-file $tempFile
  rm -f $tempFile

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
     totalCredits=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[14].displayValue'`
     usedCredits=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[15].displayValue'`
     ignore=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[16].displayValue'`
     announcement=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[17].displayValue'`
     echo $usedCredits
     echo $ignore
     echo $client
     if [[ $ignore == "No" ]]; then
        sendEmail
     fi
   done

}

getToken() {
  session=$(curl -H "Content-Type: application/json" -X POST -d '{"loginName": "'"$loginName"'","password":"'"$password"'"}' "$url/rest/ng/sessions")
  os_token=`echo ${session} | jq -r '.token'`

}

copySendingFiles() {
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
#  copySendingFiles
  getToken
  getClientsEmailId

}

main;
