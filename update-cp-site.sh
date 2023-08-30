#!/bin/bash

updateCpSite() {
# Read each CP Short title from the CSV file and perform the operation 
  while IFS=, read -r CP_SHORT_TITLE SITE_NAME; do
    CLEAN_CP_SHORT_TITLE=$(echo "$CP_SHORT_TITLE" | tr -d '"')
    GET_CP_ID=$(curl --insecure -H "X-OS-API-TOKEN: $TOKEN" -H "Content-Type: application/json" -X POST --data '[{"expr": "CollectionProtocol.shortTitle","values": ["'"$CLEAN_CP_SHORT_TITLE"'"]}]' "$URL/rest/ng/lists/data?listName=cp-list-view&maxResults=101&objectId=-1")
     
    CP_ID=$(echo "$GET_CP_ID" | jq -r '.rows[0].hidden.cpId')
    
    if [ "$CP_ID" != "null" ]; then
      echo ==============================================================
      echo "Updating site: $SITE_NAME for CP: $CP_SHORT_TITLE"
      echo ==============================================================
    else
      echo ==============================================================
      echo "$CP_SHORT_TITLE: not found"
      echo ==============================================================
    fi
    
    # Fetch the existing payload from the GET API
    EXISTING_PAYLOAD=$(curl --insecure -H "X-OS-API-TOKEN: $TOKEN" -X GET "$URL/rest/ng/collection-protocols/$CP_ID")
    
    # Create the new site entry
    NEW_SITE='{
        "siteName": '$SITE_NAME'
    }'

    # Modify the existing payload to add the new site
    MODIFIED_PAYLOAD=$(echo "$EXISTING_PAYLOAD" | jq '.cpSites += ['"$NEW_SITE"']')

    # Send PUT request for updating the site
    OUTPUT=$(curl --insecure -H "X-OS-API-TOKEN: $TOKEN" -H "Content-Type: application/json" -X PUT -d "$MODIFIED_PAYLOAD" "$URL/rest/ng/collection-protocols/$CP_ID")
    echo $OUTPUT
    echo ==========================================================
    echo "Updated CP_SITE: $SITE_NAME for $CP_SHORT_TITLE"
    echo ==========================================================
done< <(tail -n +2 "$CSV_FILE")

}

getToken() {
  SESSIONS=$(curl --insecure -H "Content-Type: application/json" -X POST --data '{"loginName": "'"$USERNAME"'","password":"'"$PASSWORD"'","domainName":"'"openspecimen"'"}' "$URL/rest/ng/sessions")
  TOKEN=`echo ${SESSIONS} | jq -r '.token'`

}

main() {
  getToken
  updateCpSite

}

if [ $# -ne 4 ]; then
    echo "Usage: $0 <url> <username> <password> <CSV_FILE>"
    exit 1
else
     URL=$1
     USERNAME=$2
     PASSWORD=$3
     CSV_FILE=$4
     main;
fi
