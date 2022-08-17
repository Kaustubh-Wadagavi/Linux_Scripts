#/bin/bash

URL=$1
USERNAME=$2
PASSWORD=$3

exportCpDef() {
  for CP_ID in "${arr[@]}"
  do
    CP_DEF=$(curl -H "X-OS-API-TOKEN: $TOKEN" -X GET "$URL/rest/ng/collection-protocols/$CP_ID/definition")
    echo $CP_DEF > cpDef_$CP_ID.json
  done

}

getAllCps() {
  CP_DETAILS=$(curl -H "X-OS-API-TOKEN: $TOKEN" -X GET "$URL/rest/ng/collection-protocols")
  arr=( $(echo $CP_DETAILS | jq -r '.[].id') )

}

authenticate() {
  API_TOKEN=$(curl -X POST -H "Content-Type: application/json" -d '{"loginName":"'"$USERNAME"'","password":"'"$PASSWORD"'","domainName":"'"$DOMAIN_NAME"'"}' "$URL/rest/ng/sessions")
  TOKEN=$(echo $API_TOKEN | jq '.token' | sed -e 's/^"//' -e 's/"$//')

  if [ ! -z $TOKEN ]; then
     return 0;
  else
     return 1;
  fi

}

main() {
  if [ ! -z $URL ] && [ ! -z $USERNAME ] && [ ! -z $PASSWORD ]; then
     authenticate
  else
     echo "USAGE ./export-cps-def.sh <URL> <USERNAME> <PASSWORD>"
     echo "Please enter URL, User Name, and Password while running the script"
     exit 1;
  fi
  
  EXIT_STATUS=$?
  if [ $EXIT_STATUS == 0 ]; then
    getAllCps
  else
   echo "Please enter valid credentials for $URL"
   exit 1;
  fi

  exportCpDef

}

main;
