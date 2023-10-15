#!/bin/bash

NICE_LABEL_URL="https://labelcloudapi.onnicelabel.com/Trigger/v1/CloudTrigger"
SUBSCRIPTION_KEY="95b04f6f743f440894d2553fa237c442"
PRINT_LABELS_FOLDER="/home/krishagni/Desktop/umcg-print-labels/print-labels"

sendLabels() {
  if [ -d $PRINT_LABELS_FOLDER ]; then
    FILE_COUNT=$(find "$PRINT_LABELS_FOLDER" -type f | wc -l)
    if [ "$FILE_COUNT" -ne 0 ]; then
      find $PRINT_LABELS_FOLDER -type f | while read FILE; 
      do
	JSON="{\"PrintJob\":{\"Block\":{\"Print\":[{\"value\":\"IdenticalCopies\",\"1\"}"
	# Read the input file line by line
        while IFS= read -r LINE
        do
         # Split the line into key and value
         IFS="=" read -ra PARTS <<< "$LINE"
         KEY="${PARTS[0]}"
         VALUE="${PARTS[1]}"

         # Escape special characters in the value
         VALUE="${VALUE//\"/\\\"}"

         # Add key-value pairs to the JSON structure
         JSON="${JSON} {\"value\":\"${KEY}\",\"${VALUE}\"}"
        done < "$FILE"

       # Close the JSON structure
       JSON="${JSON}]}}}"
       # Print the final JSON
       echo "$JSON"
       CONTENT_LENGTH=$(echo "$JSON" | jq -Rr 'length')

       GET_SENDING_STATUS=$(curl -X POST -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" -H "Content-Type: application/json" -H "Content-Length:$CONTENT_LENGTH" --data "$JSON" "https://labelcloudapi.onnicelabel.com/Trigger/v1/CloudTrigger/PRINT_LABEL")
       if [ "$GET_SENDING_STATUS" == "Label sent to printer" ]; then
         echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
         echo "$FILE SENT SUCCESSFULLY"
	 echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
         #rm $FILE
       else
	 echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
         echo "ERROR!! SENDING ERROR CODE: $GET_SENDING_STATUS"
	 echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       fi
      done
     else
       echo "=============================================="
       echo "          NO NEW FILES FOUND: BYE!            "
       echo "=============================================="
       exit 0;
      fi
   else
     echo "=============================================="
     echo "          DIRECTORY NOT FOUND: BYE!           "
     echo "=============================================="
   fi
   
}

checkAuthentication() {
   AUTH_STATUS=$(curl -o /dev/null -s -w "%{http_code}" -X POST -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" -H "Content-Type: application/json" -H "Content-Length:0" "$NICE_LABEL_URL/TESTCLOUDLINK")
   if [ "$AUTH_STATUS" -eq 200 ]; then 
     return 0;
   else
     echo "============================================================================="
     echo "       ERROR: Authentication failed with HTTP Status Code: $AUTH_STATUS      "
     echo "============================================================================="
     return 1;
   fi

}

main() {
   checkAuthentication
   SUCCESS=$?
   
   if [ $SUCCESS -eq 0 ];then
    sendLabels
   else
    echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
    echo "      Please enter valid subsription key to authenticate nice Labels APIs.     "
    echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
   fi 

}

main;
