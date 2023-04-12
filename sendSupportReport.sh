#/bin/bash

configFile=$1

sendEmail() {
  currentMonth=$(date '+%B_%Y')
  tempFile="$inputDir/files/tempfile.txt"
  toEmail="bhimsen@krishagni.com, nilesh@krishagni.com" #$emailId
  toEmail=$(echo "$toEmail" | tr -d ' ')

  if [[ $toEmail == *,* ]]; then
   mail1=$(echo $toEmail | cut -d ',' -f1)
   mail2=$(echo $toEmail | cut -d ',' -f2)
  else
   mail1=$toEmail
  fi

reportFileHtml=$(awk -F',' 'BEGIN { print "<table border=1 cellpadding=5 cellspacing=0>"} {print "<tr>"; for(i=1;i<=NF;i++) { if (NR==1 && i!=3) printf "<th><b><font color=\"blue\">%s</font></b></th>", $i; else if (i!=3) printf "<td>%s</td>", $i } print "</tr>"} END{print "</table>"}' <(sed -E 's/^([^,]*,[^,]*,[^,]*,[^,]*,)("[^"]+",)(.*)/\1\2\3/; :a; s/("[^"]*),([^"]*")/\1\2/g; ta' "$inputDir/files/$fileName"))

echo -e "To: $mail1, $mail2\ncc: $ccMail1, $ccMail2\nSubject: OpenSpecimen/$shortName: Monthly support log for $currentMonth\nContent-Type: text/html\n\n \
Hello $projectManager,<br><br> \
Below is the summary of the OpenSpecimen support activities.<br><br> \
<b>Type of Support Package:</b> $contractType<br> \
<b>Start date of contract:</b> $startDateOfContract<br> \
<b>End date of contract:</b> $endDateOfContract<br> \
<b>Total credits:</b> $totalCredits<br> \
<b>Used credits:</b> $usedCredits<br><br> \
<b>Current Version of OpenSpecimen:</b> <font color='blue'><b><i>$currentVersion</i></b></font><br><br> \
<b>Your Version of OpenSpecimen:</b> <font color='red'><b><i>$yourCurrentVersion</i></b></font><br><br> \
<b>Please find below details of support tickets:</b><br><br> \
<font color='red'><b>Here are some interesting OpenSpecimen news for this month: </b></font><br> \
$(echo "$announcement")<br><br> \
$reportFileHtml" > "$tempFile"

if [[ $toEmail == *,* ]]; then
    curl --ssl-reqd --url 'smtps://smtp.gmail.com:465' -u "$fromEmail:$emailPassword" --mail-from "$fromEmail" -v --mail-rcpt "$mail1" --mail-rcpt "$mail2" --mail-rcpt "$ccMail1" --mail-rcpt "$ccMail2" --upload-file "$tempFile"
else
    curl --ssl-reqd --url 'smtps://smtp.gmail.com:465' -u "$fromEmail:$emailPassword" --mail-from "$fromEmail" -v --mail-rcpt "$mail1" --mail-rcpt "$ccMail1" --mail-rcpt "$ccMail2" --upload-file "$tempFile"
fi

}

getClientDetails() {
   tail -n +2 "$inputDir/output_file.csv" | while IFS=, read -r id ppid fileName
   do
     echo =========================================================================
     echo $ppid
     echo =========================================================================
     getSupportDetails=$(curl -H "X-OS-API-TOKEN: $os_token" -H "Content-Type: application/json" -X GET "$url/rest/ng/collection-protocol-registrations/$id")
     emailId=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[3].displayValue'`
     shortName=`echo ${getSupportDetails} | jq -r '.ppid'`
     projectManager=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[2].displayValue'`
     contractType=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[4].displayValue'`
     startDateOfContract=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[8].displayValue'`
     endDateOfContract=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[9].displayValue'`
     if [[ $contractType != "Platinum" ]]
     then
       totalCredits=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[14].displayValue'`
     fi
     usedCredits=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[15].displayValue'`
     ignore=`echo ${getSupportDetails} | jq -r '.participant.extensionDetail.attrs[16].displayValue'`

     getAnnouncement=$(curl -X GET -H "X-OS-API-TOKEN: $os_token" -H "Content-Type: application/json" "$url/rest/ng/collection-protocols/1")
     announcement=`echo ${getAnnouncement} | jq -r '.extensionDetail.attrs[0].value'`
     currentVersion=`echo ${getAnnouncement} | jq -r '.extensionDetail.attrs[1].value'`
     yourCurrentVersion="v9.1.RC1" # `echo ${getAnnouncement} | jq -r '.extensionDetail.attrs[].value'`
     if [[ $ignore != "Yes" ]] && [[ $contractType != "Yet To Go-Live" ]] && [[ $contractType != "Closed" ]] ; then
        sendEmail
     fi
   done

}

downloadFile() {
  curl -X GET -H "X-OS-API-TOKEN: $os_token" -H "Content-Type: application/json" "$url/rest/ng/export-jobs/$ID/output" > ExportJob_$ID.zip
  if [ -d "$inputDir" ]; then
     rm -rf "$inputDir"
  fi
  mkdir -p "$inputDir"
  unzip ExportJob_$ID.zip -d $inputDir
  rm ExportJob_$ID.zip
  echo '"id","ppid","fileName"' > "$inputDir/output_file.csv"
  while IFS="," read line
  do
   if [[ "$line" == *".csv"* ]]; then
     id=$(echo "$line" | cut -d ',' -f 1 | grep -oE '[0-9]+')
     ppid=$(echo "$line" | cut -d ',' -f 3)
     fileName=$(echo "$line" | grep -oE '[^",]+\.csv')
     echo $id,$ppid,$fileName >> "$inputDir/output_file.csv"
   fi
  done < "$inputDir/output.csv"


}

exportParticipants() {
   JOB_DETAILS=$(curl -X POST -H "X-OS-API-TOKEN: $os_token" -H "Content-Type: application/json" -d '{ "objectType":"'"cpr"'", "params": { "cpId": "'"1"'" } }' "$url/rest/ng/export-jobs")

   ID=`echo ${JOB_DETAILS} | jq -r '.id'`
   STATUS=`echo ${JOB_DETAILS} | jq -r '.status'`

   if [[ "$STATUS" == "IN_PROGRESS" ]]; then
       sleep 300
   fi

}


getToken() {
  session=$(curl -H "Content-Type: application/json" -X POST -d '{"loginName": "'"$loginName"'","password":"'"$password"'"}' "$url/rest/ng/sessions")
  os_token=`echo ${session} | jq -r '.token'`

}

main() {
  if [ ! -f "$configFile" ]
  then
    echo "Please input the config file"
    exit 0;
  fi
  
 source $configFile
 getToken
 exportParticipants
 downloadFile
 getClientDetails

}

main;
