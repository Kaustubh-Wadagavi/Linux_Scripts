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
   mail1=$toEmail
  fi
  announcement="<ol>
    <li><a href='https://openspecimen.atlassian.net/wiki/x/BYDWmg'><span style='background-color:hsl(0, 0%, 100%);color:hsl(0, 75%, 60%);'><strong>v10.1 released</strong></span></a></li>
    <li><a href='https://openspecimen.org/oscon23'><span style='background-color:hsl(0, 0%, 100%);color:hsl(210, 75%, 60%);'><strong>Register for OSCON23&nbsp;(23-26 July, San Diego)</strong></span></a></li>
    <li><span style='background-color:hsl(0, 0%, 100%);color:hsl(30, 75%, 60%);font-family:Arial, Helvetica, sans-serif;'><strong>Kaustubh Wadagavi is getting married</strong></span></li>
</ol>"

  reportFileHtml=$(awk -F',' 'BEGIN { print "<table border=1 cellpadding=5 cellspacing=0>"} {print "<tr>"; for(i=1;i<=NF;i++) {if (NR==1) printf "<th><b><font color=\"blue\">%s</font></b></th>", $i; else printf "<td>%s</td>", $i} print "</tr>"} END{print "</table>"}' $reportFile)

  echo -e "To: $mail1, $mail2\ncc: $ccEmail1, $ccEmail2\nSubject: OpenSpecimen/$shortName: Monthly support log for $currentMonth\nContent-Type: text/html\n\n \
Hello $projectManager,<br><br> \
Below is the summary of the OpenSpecimen support activities.<br><br> \
<b>Type of Support Package:</b> $contractType<br> \
<b>Start date of contract:</b> $startDateOfContract<br> \
<b>End date of contract:</b> $endDateOfContract<br> \
<b>Total credits:</b> $totalCredits<br> \
<b>Used credits:</b> $usedCredits<br><br> \
<b>Please find below details of support tickets:</b><br><br> \
<font color='red'><b>Here are some interesting OpenSpecimen news for this month: </b></font><br> \
$(echo "$announcement")<br><br> \
$reportFileHtml" > $tempFile

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
#    announcement=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[17].displayValue'`
     if [[ $ignore != "Yes" ]] && [[ $contractType != "Platinum" ]] && [[ $contractType != "Yet To Go-Live" ]] ; then
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
