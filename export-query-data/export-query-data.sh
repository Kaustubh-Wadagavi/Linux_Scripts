#!/bin/bash

configFile=$1

getFile() {
  getStatusCode=$(curl -s -o /dev/null -w "%{http_code}" -H "X-OS-API-TOKEN: $token" -H "Content-Type: application/json" --request GET "$url/rest/ng/query/export?fileId=$dataFileId")
  if [[ "$getStatusCode" -eq "400" ]]
  then
      echo "Please wait the export of the file is still running..."
      sleep 10;
      getFile
  elif [[ "$getStatusCode" -eq "200" ]]
  then
      curl -H "X-OS-API-TOKEN: $token" -H "Content-Type: application/json" -X GET "$url/rest/ng/query/export?fileId=$dataFileId" >> "$outputFile"
      echo "The query output is stored in a file: $outputFile"
  fi
  
}
	
exportQuery() {
  getDataFile=$(curl -H "X-OS-API-TOKEN: $token" -H "Content-Type: application/json" -X POST --data '{ "savedQueryId": '$queryId',"drivingForm": "'"$drivingForm"'","cpId":-1
,"runType": "Export","aql": "'"$aql"'","indexOf": "Specimen.label","wideRowMode": "'"$wideRowMode"'","outputColumnExprs": false,"caseSensitive": false
}' "$url/rest/ng/query/export")
  dataFileId=$(echo "$getDataFile" | jq -r '.dataFile')
  echo $dataFileId

  if [[ -z "$dataFileId" ]]
  then
    echo "Something went wrong, please check the JSON object that you are seding"
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
  if [ -z "$configFile" ]
  then
    echo "echo "Error: configFile argument is missing.""
    echo "Usage: ./export-query-data.sh query-details.config"
    exit 1;
  else
    source $configFile
  fi
  
}

main () {
  checkInputs
  startSession
  exportQuery
  getFile

}

main;
