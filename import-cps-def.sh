#/bin/bash

URL=$1
USERNAME=$2
PASSWORD=$3
DIR=$4

importCpJsonFiles() {
  LIST_OF_FILES=($(find $DIR -type f -name "*.json"))
  if ((${#LIST_OF_FILES[@]})); then
    for FILE in "${LIST_OF_FILES[@]}"
    do
      curl -H "X-OS-API-TOKEN: $TOKEN" -X POST --form "file=@$FILE" "$URL/rest/ng/collection-protocols/definition"
    done
  else
    return 1;
  fi

  
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
  if [ ! -z $URL ] && [ ! -z $USERNAME ] && [ ! -z $PASSWORD ] && [ -d $DIR ]; then
     authenticate
  else
     echo "USAGE ./export-cps-def.sh <URL> <USERNAME> <PASSWORD> <DIR>"
     echo "Please enter URL, User Name, Password and DIR name where JSON file is stored while running the script"
     exit 1;
  fi

  EXIT_STATUS=$?
  if [ $EXIT_STATUS == 0 ]; then
    importCpJsonFiles
  else
   echo "Please enter valid credentials for $URL"
   exit 1;
  fi

  IMPORT_CODE=$?
  if [ $IMPORT_CODE == 1 ]; then
    echo "JSON files are not found to import in $DIR for $URL"
  else
    exit 0;
  fi

}

main;
