#!/bin/bash

configFile=$1

updateCredits() {
 tail -n +2 "$inputDir/output_file.csv" | while IFS=, read -r id ppid fileName
 do
   totalCredits=$(awk -F',' 'NR>1 && $4 ~ /^[0-9]+$/ { sum+=$4 } END { print sum }' "$inputDir/files/$fileName")
   echo ================================================================
   echo $ppid: $totalCredits
   echo ===============================================================
   curl -X PUT -H "X-OS-API-TOKEN: $os_token" -H "Content-Type: application/json" -X PUT -d '{"participant":{"extensionDetail":{"formCaption":"Krishagni_clients","attrs":[{"name":"used_credits","value":"'"$totalCredits"'"}]}}}' "$url/rest/ng/collection-protocol-registrations/$id"
 done

}

downloadFile(){
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
  updateCredits

}

main;
