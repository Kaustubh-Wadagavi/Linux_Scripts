#!/bin/bash

NICE_LABEL_URL="https://labelcloudapi.onnicelabel.com/Trigger/v1/CloudTrigger"
SUBSCRIPTION_KEY="<PRIMARY SUBSCRIPTION KEY"
OS_PRINTER_CLIENT="/home/krishagni/Desktop/os-printer-client"
PRINT_LABELS_FOLDER="/home/krishagni/Desktop/umcg-print-labels/print-labels"

sendLabels() {
  if [ -d $PRINT_LABELS_FOLDER ]; then
    FILE_COUNT=$(find "$PRINT_LABELS_FOLDER" -type f | wc -l)
    if [ "$FILE_COUNT" -ne 0 ]; then
      find $PRINT_LABELS_FOLDER -type f | while read FILE; 
      do
	CONTENT_LENGTH=$(stat -c %s "$FILE")
        JSON=$(cat $FILE)
        GET_SENDING_STATUS=$(curl -X POST -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" -H "Content-Type: application/json" -H "Content-Length:$CONTENT_LENGTH" --data "$JSON" "https://labelcloudapi.onnicelabel.com/Trigger/v1/CloudTrigger/PRINT_LABEL")
        if [ "$GET_SENDING_STATUS" == "Label sent to printer" ]; then
          echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          echo "$FILE SENT SUCCESSFULLY"
	  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          rm $FILE
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

runOsAPIClient() {
 echo Starting OS API Client...
 #command
 #sleep 5; 
 
}

main() {
   runOsAPIClient
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
