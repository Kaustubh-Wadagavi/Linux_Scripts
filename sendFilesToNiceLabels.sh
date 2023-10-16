#!/bin/bash

NICE_LABEL_URL="https://labelcloudapi.onnicelabel.com/Trigger/v1/CloudTrigger"
SUBSCRIPTION_KEY="95b04f6f743f440894d2553fa237c442"
PRINT_LABELS_FOLDER="/home/krishagni/Desktop/umcg-print-labels/print-labels"
TEMP_FILE="/tmp/labels-list.txt"
LOCK_FILE="/tmp/labels.lock"

sendLabels() {
  JSON_OUTPUT='{"PrintJob": {"Block":{'
  while IFS= read -r FILE; do
    JSON_OUTPUT+='"Print": ['
    JSON_OUTPUT+='{"value": "IdenticalCopies","1"}'
    while IFS='=' read -r KEY VALUE; do
      KEY=$(echo "$KEY" | awk '{$1=$1; print}')
      VALUE=$(echo "$VALUE" | awk '{$1=$1; print}')
      JSON_OUTPUT+='{"value": "'"$KEY"'","'"$VALUE"'"}'
    done < "$FILE"
    rm "$FILE"
    JSON_OUTPUT+=']'
  done < ${TEMP_FILE}
  JSON_OUTPUT+='}}}'
  
  CONTENT_LENGTH=$(echo "$JSON_OUTPUT" | jq -Rr 'length')

  GET_SENDING_STATUS=$(curl -X POST -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" -H "Content-Type: application/json" -H "Content-Length:$CONTENT_LENGTH" --data "$JSON_OUTPUT" "https://labelcloudapi.onnicelabel.com/Trigger/v1/CloudTrigger/PRINT_LABEL")
   
  if [ "$GET_SENDING_STATUS" == "Label sent to printer" ]; then
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "$JSON_OUTPUT SENT SUCCESSFULLY"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  else
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "ERROR!! SENDING ERROR CODE: $GET_SENDING_STATUS"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  fi

}

createLabelsFilesList() {
   if [ -d $PRINT_LABELS_FOLDER ]; then
     FILE_COUNT=$(find "$PRINT_LABELS_FOLDER" -type f | wc -l)
     if [ "$FILE_COUNT" -ne 0 ]; then
      find $PRINT_LABELS_FOLDER -type f | while read FILE; 
      do
       echo ${FILE} >> $TEMP_FILE
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
    trap "rm -f $TEMP_FILE" 0 1 15
    trap "rm -f $LOCK_FILE; exit" INT TERM EXIT
    echo $$ > $LOCK_FILE
    createLabelsFilesList
    sendLabels
   else
    echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
    echo "      Please enter valid subsription key to authenticate nice Labels APIs.     "
    echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
   fi 
   
   rm -f $TEMP_FILE
   rm -f $LOCK_FILE
   exit 0;

}

main;
