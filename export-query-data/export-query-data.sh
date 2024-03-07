#!/bin/bash

getFile() {
  while true; do
    curl -s -i -H "X-OS-API-TOKEN: $token" -H "Content-Type: application/json" -X GET "$url/rest/ng/query/export?fileId=$dataFileId" -o "output_file"
 
    statusCode=$(awk 'NR==1{print $2}' output_file)
    
    if [[ "$statusCode" == "400" ]]
    then
       jsonObject=$(perl -0777 -ne 'print $1 if /\[(.*?)\]/s' output_file)
       code=$(echo "$jsonObject" | jq -r '.code')
       message=$(echo "$jsonObject" | jq -r '.message')
    fi 

    if [[ "$code" == "QUERY_EXPORT_DATA_IN_PROGRESS" && "$statusCode" == "400" ]]; then
      echo "Message: $message"
      sleep 10;
    elif [[ "$statusCode" == "200" ]]; then
      mv output_file "$outputFile"
      echo "The query output is stored in a file: $outputFile"
      break;
    elif [[ "$code" != "QUERY_EXPORT_DATA_IN_PROGRESS" && "$statusCode" == "400" ]]; then 
      echo "Error: $jsonObject"
      exit 1;
    fi
  done

}
	
exportQuery() {
  getDataFile=$(curl -H "X-OS-API-TOKEN: $token" -H "Content-Type: application/json" -X POST --data '{ "savedQueryId": '$queryId',"drivingForm": "'"$drivingForm"'","cpId":-1,"aql": "'"$aql"'","wideRowMode": "'"$wideRowMode"'"}' "$url/rest/ng/query/export")
  
  dataFileId=$(echo "$getDataFile" | jq -r '.dataFile')

  if [[ -z "$dataFileId" ]]
  then
    echo "Error: $getDataFile"
    exit 1;
  fi

}

startSession() {
  sessions=$(curl -H "Content-Type: application/json" --request POST --data '{"loginName": "'"$username"'","password":"'"$password"'","domainName":"'"openspecimen"'"}' "$url/rest/ng/sessions")
  
  token=`echo ${sessions} | jq -r '.token'`
  
  if [[ -z "$token" ]]
  then
     echo "Please enter valid credentials..."
     exit 1;
  fi

}

checkInputs() {
  local required=("username" "password" "url" "aql" "queryId" "drivingForm" "wideRowMode")
  
  for arg in "${required[@]}"; do
    local value="${!arg}"
    if [[ -z "$value" ]]; then
      echo "Error: $arg is missing."
      exit 1
    fi
  done  

}

main () {
  configFile=$1
  
  if [ -z "$configFile" ]
  then
    echo "echo "Error: configFile argument is missing.""
    echo "Usage: ./export-query-data.sh query-details.config"
    exit 1;
  fi

  source "$configFile"
  checkInputs "$username" "$password" "$url" "$aql" "$queryId" "$drivingForm" "$wideRowMode"
  startSession
  exportQuery
  getFile
  exit 0;

}

main "$@";
