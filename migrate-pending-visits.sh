#!/bin/bash

dbUser=
dbPass=
dbName=
connectionString=""

insertPendingVisits() {
  insertStatement="INSERT INTO catissue_specimen_coll_group SELECT * FROM catissue_specimen_coll_group_bkp WHERE IDENTIFIER IN ($identifiers);"
  echo "set autocommit off; 
  $insertStatement
  commit;" | sqlplus -S -L "${dbUser}/${dbPass}@${connectionString}"

}

createBatchAndInsert() {
  local counter=0
  local updateCount=100

  while IFS=, read -r identifier; do
    if [ -n "$identifier" ]; then
      identifiers+=($identifier)
      if [ -n "$identifiers" ]; then
        identifiers+=", $identifier"
      else
        identifiers="$identifier"
      fi
      
      ((counter++))
      if (( counter % updateCount == 0 )); then
        # Execute the batch and commit after every 10 records
	echo $identifiers
        insertPendingVisits
        echo "updated $counter records"
        identifiers=""
      fi
    fi
  done < <(tail -n +2 "$visitIdsList")

  #sending remaining records
  if [ "$counter" -gt 0 ] && [ ! -z "$identifiers" ]; then
    insertPendingVisits
    echo "Updated $counter records"
    identifiers=""
  fi

}

main() {
  if [ $# -lt 1 ]; then
    echo "Error: Missing arguments."
    echo "Usage: $0 <visitIdsList.csv>"
    exit 1
  fi

  visitIdsList=$1

  if [ ! -f "$visitIdsList" ]; then
    echo "Error: $visitIdsList is not a valid file."
    exit 1
  fi

  createBatchAndInsert

}

main "$@";
