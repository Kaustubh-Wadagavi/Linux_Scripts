#!/bin/bash

dbUser=CATISSUE_UPGRADE
dbPass=catissueupgrade
dbName=
connectionString=
cpShortTitles=""

insertData() {
  echo $cpShortTitles
#  insertStatementMySQL="
#   INSERT INTO catissue_form_context (
#    container_id, 
#    entity_type, 
#    cp_id,
#    sort_order,
#    is_multirecord,
#    is_sys_form,
#    deleted_on,
#    entity_id,
#    notifs_enabled,
#    data_in_notif
#  ) 
#  SELECT
#    forms.identifier,
#    '$level',
#    cp.identifier,
#    NULL,
#    0,
#    0,
#    NULL,
#    NULL,
#    0,
#    0
#  FROM
#    catissue_collection_protocol cp,
#    dyextn_containers forms
#  WHERE
#    cp.short_title IN ($cpShortTitles)
#    AND forms.caption = '${formName}'
#"
#   mysql -u$dbUser -p$dbPass -D$dbName -e "set autocommit=0; $insertStatementMySQL; commit;"
  
  insertStatementOracle="
  INSERT INTO catissue_form_context (
    identifier,                       
    container_id,
    entity_type,
    cp_id,
    sort_order,
    is_multirecord,
    is_sys_form,
    deleted_on,
    entity_id,
    notifs_enabled,
    data_in_notif
  )
  SELECT
    catissue_form_context_seq.nextval,
    forms.identifier,
    '$level',
    cp.identifier,
    NULL,
    0,
    0,
    NULL,
    NULL,
    0,
    0
  FROM
    catissue_collection_protocol cp,
    dyextn_containers forms
  WHERE
    cp.identifier IN ($cpShortTitles)
    AND forms.caption = '$formName';"
  
  echo "set autocommit off; 
  $insertStatementOracle 
  commit;" | sqlplus -S -L "${dbUser}/${dbPass}@${connectionString}"

} 

createBatchAndInsert() {
  local counter=0
  local insertCount=5

  while IFS=, read -r shortTitle; do
    if [ -n "$shortTitle" ]; then
      shortTitle=$(sed -e 's/^"//' -e 's/"$//' <<< "$shortTitle")
      # Store the short title in the array
      cpShortTitles+=($shortTitle)
      if [ -n "$cpShortTitles" ]; then
        cpShortTitles+=", $shortTitle"
      else
        cpShortTitles="$shortTitle"
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

  createBatchAndInsert

}

main "$@"
