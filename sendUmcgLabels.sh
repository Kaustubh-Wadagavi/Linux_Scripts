#!/bin/bash

NICE_LABEL_URL=
SUBSCRIPTION_KEY=
TRIGGER_ID=
PRINT_LABELS_FOLDER=
TEMP_FILE="/tmp/labels-list.txt"
LOCK_FILE="/tmp/labels.lock"

sendLabels() {
  JSON_OUTPUT='{"PrintJob": { "Print": ['
  FIRST_OBJECT=true

  while IFS= read -r FILE; do
    if [ "$FIRST_OBJECT" = false ]; then
     JSON_OUTPUT+=','
    fi

    OBJECT=''
    OBJECT+='{'
    OBJECT+='"IdenticalCopies":"1",'

    while IFS='=' read -r KEY VALUE; do
      KEY=$(echo "$KEY" | awk '{$1=$1; print}')
      VALUE=$(echo "$VALUE" | awk '{$1=$1; print}')
      OBJECT+='"'"$KEY"'":"'"$VALUE"'",'
    done < "$FILE"

    UPDATED_OBJECT=${OBJECT%,} # Remove the trailing comma from the object
    JSON_OUTPUT+="${UPDATED_OBJECT}"
    JSON_OUTPUT+='}'
    FIRST_OBJECT=false
    rm $FILE
  done < ${TEMP_FILE}

  JSON_OUTPUT+=']}}'
  CONTENT_LENGTH=$(echo "$JSON_OUTPUT" | jq -Rr 'length')

  GET_SENDING_STATUS=$(curl -X POST -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" -H "Content-Type: application/json" -H "Content-Length:$CONTENT_LENGTH" --data "$JSON_OUTPUT" "https://labelcloudapi.onnicelabel.com/Trigger/v1/CloudTrigger/$TRIGGER_ID")

  if [ "$GET_SENDING_STATUS" == "Labels printed " ]; then
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

main() {
  trap "rm -f $TEMP_FILE" 0 1 15
  trap "rm -f $LOCK_FILE; exit" INT TERM EXIT
  echo $$ > $LOCK_FILE
  createLabelsFilesList
  sendLabels
    
  rm -f $TEMP_FILE
  rm -f $LOCK_FILE
  exit 0;

}

main;
