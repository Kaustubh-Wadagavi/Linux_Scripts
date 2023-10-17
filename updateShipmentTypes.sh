#!/bin/bash

dbUser=CATISSUE_UPGRADE
dbPass=catissueupgrade
dbName=
connectionString=""

updateShipmentType() {
  updateStatement="update os_shipments set TYPE='CONTAINERS' WHERE identifier IN ($shipmentIdentifiers);"
  echo "set autocommit off; 
  $updateStatement
  commit;" | sqlplus -S -L "${dbUser}/${dbPass}@${connectionString}"

}

createBatchAndUpdate() {
  local counter=0
  local updateCount=100

  while IFS=, read -r identifier; do
    if [ -n "$identifier" ]; then
      # Store the short title in the array
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
	exit 0;
        updateShipmentType
        echo "updated $counter records"
        # Reset the batch
        identifiers=""
      fi
    fi
  done < <(tail -n +2 "$shipmentIdsList")

  #sending remaining records
  if [ "$counter" -gt 0 ] && [ ! -z "$identifiers" ]; then
    #updateData
    echo "Updated $counter records"
    identifiers=""
  fi

}

main() {
  if [ $# -lt 1 ]; then
    echo "Error: Missing arguments."
    echo "Usage: $0 <containerShipmentIdsList.csv>"
    exit 1
  fi

  shipmentIdsList=$1

  # Check if cpList is a valid file
  if [ ! -f "$shipmentIdsList" ]; then
    echo "Error: $cpList is not a valid file."
    exit 1
  fi

  createBatchAndUpdate

}

main "$@";
