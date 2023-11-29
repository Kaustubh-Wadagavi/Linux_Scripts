#!/bin/bash

NICE_LABEL_URL=""
SUBSCRIPTION_KEY=""
TRIGGER_ID="UMCG_BIMS_PRINTLABEL"
PRINT_LABELS_FOLDER="/usr/local/openspecimen/os-test/data/print-labels"
TEMP_FILE="/tmp/labels-list.txt"
LOCK_FILE="/tmp/labels.lock"

sendLabels() {
  JSON_OUTPUT='{"PrintJob": { "Print": ['
  FIRST_OBJECT=true

  while IFS= read -r FILE; do
    if [ "$FIRST_OBJECT" = false ]; then
     JSON_OUTPUT+=','
    fi

    OBJECT='{ "Quantity": "1", "IdenticalCopies": "1", '
    OTHER_KEYS=''

    while IFS='=' read -r KEY VALUE; do
      KEY=$(echo "$KEY" | awk '{$1=$1; print}')
      VALUE=$(echo "$VALUE" | awk '{$1=$1; print}')

      # Add the "Specimen Quantity" key-value pair
        if [[ $KEY == "Quantity" ]]; then
          KEY="Specimen Quantity"
        fi

        if [ "$KEY" == "Label Design" ]; then
          LABEL_DESIGN='"'"$KEY"'":"'"$VALUE"'"'
        else
          OBJECT+='"'"$KEY"'":"'"$VALUE"'",'
        fi
    done < "$FILE"
    # Trim trailing commas and spaces from OBJECT and OTHER_KEYS strings
    OBJECT=$(echo "$OBJECT" | sed 's/\(.*\),/\1/')
    LABEL_DESIGN=$(echo "$LABEL_DESIGN" | sed 's/\(.*\),/\1/')

    JSON_OUTPUT+="$OBJECT, $LABEL_DESIGN }"
    FIRST_OBJECT=false
    rm $FILE
  done < "$TEMP_FILE"

  JSON_OUTPUT+=']}}'
  
  JSON_OUTPUT_BEAUTIFY=$(echo "$JSON_OUTPUT" | jq '.')
  echo $JSON_OUTPUT_BEAUTIFY

  GET_SENDING_STATUS=$(curl -X POST -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" -H "Content-Type: application/json" --data "$JSON_OUTPUT_BEAUTIFY" "https://labelcloudapi.onnicelabel.com/Trigger/v1/CloudTrigger/$TRIGGER_ID")

  if [ "$GET_SENDING_STATUS" == "Labels printed " ]; then
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "$JSON_OUTPUT_BEAUTIFY SENT SUCCESSFULLY"
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
