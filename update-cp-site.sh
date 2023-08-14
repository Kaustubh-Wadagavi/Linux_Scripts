#!/bin/bash

updateCpSite() {
# Read each ID from the CSV file and perform the operation
while IFS=, read -r ID _; do
    # Fetch the existing payload from the GET API
    EXISTING_PAYLOAD=$(curl -H "X-OS-API-TOKEN: $TOKEN" -X GET "$URL/rest/ng/collection-protocols/$ID")
    
    # Create the new site entry
    NEW_SITE='{
        "siteName": "'$SITE_NAME'"
    }'

    # Modify the existing payload to add the new site
    MODIFIED_PAYLOAD=$(echo "$EXISTING_PAYLOAD" | jq '.cpSites += ['"$NEW_SITE"']')

    # Send PUT request using curl
    OUTPUT=$(curl -H "X-OS-API-TOKEN: $TOKEN" -H "Content-Type: application/json" -X PUT -d "$MODIFIED_PAYLOAD" "$URL/rest/ng/collection-protocols/$ID")
    echo $OUTPUT

    echo "Updated payload for ID: $ID"
done< <(tail -n +2 "$CSV_FILE")

}

getToken() {
  SESSIONS=$(curl -H "Content-Type: application/json" -X POST --data '{"loginName": "'"$USERNAME"'","password":"'"$PASSWORD"'","domainName":"'"openspecimen"'"}' "$URL/rest/ng/sessions")
  TOKEN=`echo ${SESSIONS} | jq -r '.token'`

}

main() {
  echo main
  getToken
  updateCpSite

}

if [ $# -ne 5 ]; then
    echo "Usage: $0 <url> <username> <password> <siteName> <CSV_FILE>"
    exit 1
else
     URL=$1
     USERNAME=$2
     PASSWORD=$3
     SITE_NAME=$4
     CSV_FILE=$5
     main;
fi
