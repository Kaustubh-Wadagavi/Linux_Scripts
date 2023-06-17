#!/bin/bash

dbUser=os_tester
dbPass=secrete
dbName=master
connectionString=
cpShortTitles=""

insertData() {
  echo $cpShortTitles
  insertStatementMySQL="insert into catissue_form_context (container_id, entity_type, cp_id, sort_order, is_multirecord, is_sys_form, deleted_on, entity_id, notifs_enabled, data_in_notif) select forms.identifier, '$level', cp.identifier, null, 0, 0, null, null, 0, 0 from catissue_collection_protocol cp, dyextn_containers forms where cp.short_title in ( $cpShortTitles ) and forms.caption = '$formName'" 
  mysql -u$dbUser -p$dbPass -D$dbName -e "set autocommit=0; $insertStatementMySQL; commit;"
  
  #insertStatementOracle="insert into catissue_form_context ( container_id, entity_type, cp_id, sort_order, is_multirecord, is_sys_form, deleted_on, entity_id, notifs_enabled, data_in_notif ) SELECT forms.identifier, '$level', cp.identifier, null, 0, 0, null, null, 0, 0 FROM catissue_collection_protocol cp, dyextn_containers forms where cp.short_title in ( $cpShortTitles ) and forms.caption = '$formName'"
  #echo "set autocommit off;
  #$insertStatementOracle
  #commit;" | sqlplus -S -L "${DB_USERNAME}/${DB_PASSWORD}@${DB_CONNECTION}"

} 

getCpShortTitles() {
  counter=0
  local insertCount=1

  while IFS=, read -r shortTitle; do
    if [ -n "$shortTitle" ]; then
      shortTitle=$(sed -e 's/^"//' -e 's/"$//' <<< "$shortTitle")
      # Store the short title in the array
      cpShortTitles+=("'$shortTitle'")
      if [ -n "$cpShortTitles" ]; then
        cpShortTitles+=", '$shortTitle'"
      else
        cpShortTitles="'$shortTitle'"
      fi

      ((counter++))
      if (( counter % insertCount == 0 )); then
        # Execute the batch and commit after every 10 records
        insertData
        echo "Inserted $counter records"
        # Reset the batch
        cpShortTitles=""
      fi
    fi
  done < <(tail -n +2 "$cpList")

  #sending remaining records
  if [ "$counter" -gt 0 ] && [ ! -z "$cpShortTitles" ]; then
    insertData
    echo "Inserted $counter records"
    cpShortTitles=""
  fi

}

main() {
  if [ $# -lt 3 ]; then
    echo "Error: Missing arguments."
    echo "Usage: $0 <cpList.csv> '<formName>' <level>"
    exit 1
  fi

  # Assign the command line arguments to variables
  cpList=$1
  formName="$2"
  level=$3

  # Check if cpList is a valid file
  if [ ! -f "$cpList" ]; then
    echo "Error: $cpList is not a valid file."
    exit 1
  fi

  # Check if formName is a String
  if ! [[ "$formName" =~ ^[a-zA-Z\ ]+$ ]]; then
    echo "Error: formName should be a string."
    exit 1
  fi

  if ! [[ "$level" =~ ^[a-zA-Z]+$ ]]; then
    echo "Error: level should be a string."
    exit 1
  fi

  getCpShortTitles

}

main "$@"
