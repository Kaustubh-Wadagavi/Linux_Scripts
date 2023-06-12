#!/bin/bash

# Define variables
CSV_FILE="sp-custom-fields.csv"
DB_USERNAME="CATISSUE_UPGRADE"
DB_PASSWORD="catissueupgrade"
DB_CONNECTION=""
COMMIT_FREQUENCY=5
counter=0

insertData() {
  batch=$(echo "$batch" | sed -e 's/^[[:space:]]*//')
  echo "SET AUTOCOMMIT OFF;
  $batch
  COMMIT;" | sqlplus -S -L "${DB_USERNAME}/${DB_PASSWORD}@${DB_CONNECTION}"
}

# Read CSV file and insert records
batch=""
while IFS=',' read -r identifier label created_on_var created_by_var last_modified_var last_modified_by_var
do
    # Remove double quotes from variables
    identifier="${identifier//\"/}"
    label="${label//\"/}"
    created_on="${created_on_var//\"/}"
    created_by="${created_by_var//\"/}"
    last_modified="${last_modified_var//\"/}"
    last_modified_by="${last_modified_by_var//\"/}"
    
    if [[ -z "$created_on" ]]; then
        created_on="NULL"
    else
        created_on="'$created_on'"
    fi

    if [[ -z "$created_by" ]]; then
        created_by="NULL"
    else
	created_by="'$created_by'"
    fi

    if [[ -z "$last_modified" ]]; then
        last_modified="NULL"
    else
        last_modified="'$last_modified'"
    fi

    if [[ -z "$last_modified_by" ]]; then
        last_modified_by="NULL"
    else
        last_modified_by="'$last_modified_by'"
    fi
    echo "$identifier, $label, $created_on, $created_by, $last_modified, $last_modified_by"
    # Build the insert statement
    insert_statement="INSERT INTO catissue_abstract_specimen (identifier, label, created_on, created_by, last_modified, last_modified_by) VALUES ($identifier, '$label', $created_on, $created_by, $last_modified, $last_modified_by)"

    # Append the insert statement to the batch
    batch+=" $insert_statement;"$'\n'

    ((counter++))
    if (( counter % COMMIT_FREQUENCY == 0 )); then
        # Execute the batch and commit after every 100 records
	echo $batch
	insertData
        echo "Inserted $counter records"
        # Reset the batch
        batch=""
        exit;    
    fi
done < <(tail -n +2 "$CSV_FILE")
