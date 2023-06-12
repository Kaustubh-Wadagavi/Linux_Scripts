#!/bin/bash

# Define variables
CSV_FILE="sp-custom-fields.csv"
DB_USERNAME="CATISSUE_UPGRADE"
DB_PASSWORD="catissueupgrade"
DB_CONNECTION=""
COMMIT_FREQUENCY=100
counter=0

# Connect to Oracle and set autocommit off
sqlplus -S "${DB_USERNAME}/${DB_PASSWORD}@${DB_CONNECTION}" <<EOF
    SET AUTOCOMMIT OFF;
EOF

# Read CSV file and update records
while IFS=',' read -r identifier label created_on created_by last_modified last_modified_by
do
    #Need to fix the command 
    # Connect to Oracle and update the record
    #sqlplus -S "${DB_USERNAME}/${DB_PASSWORD}@${DB_CONNECTION}" <<EOF
       # INSERT INTO catissue_abstract_specimen (identifier, label, created_on, created_by, last_modified, last_modified_by)
     #   VALUES ($identifier, '$label', '$created_on', $created_by, '$last_modified', $last_modified_by);
EOF

    counter=$((counter+1))

    if ((counter % COMMIT_FREQUENCY == 0)); then
        sqlplus -S "${DB_USERNAME}/${DB_PASSWORD}@${DB_CONNECTION}" <<EOF
            COMMIT;
EOF
        echo "Committed after $counter records"
    fi

    echo "Inserted record: identifier=$identifier, label=$label, created_on=$created_on, created_by=$created_by, last_modified=$last_modified, last_modified_by=$last_modified_by"
done < "$CSV_FILE"

# Commit remaining records
sqlplus -S "${DB_USERNAME}/${DB_PASSWORD}@${DB_CONNECTION}" <<EOF
    COMMIT;
EOF

echo "Committed all records"
