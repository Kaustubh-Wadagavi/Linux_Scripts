#!/bin/bash

# Define variables
CSV_FILE="sp-custom-fields.csv"
DB_USERNAME="CATISSUE_UPGRADE"
DB_PASSWORD="catissueupgrade"
DB_CONNECTION=""
COMMIT_FREQUENCY=100
counter=0

# Set autocommit off
sqlplus -S "${DB_USERNAME}/${DB_PASSWORD}@${DB_CONNECTION}" <<EOF
    SET AUTOCOMMIT OFF;
EOF

# Read CSV file and insert records
counter=0
while IFS=',' read -r identifier label created_on created_by last_modified last_modified_by
do
    # Handle empty values
    if [[ -z "$created_on" ]]; then
        created_on="NULL"
    else
        created_on="'$created_on'"
    fi

    if [[ -z "$created_by" ]]; then
        created_by="NULL"
    fi

    if [[ -z "$last_modified" ]]; then
        last_modified="NULL"
    else
        last_modified="'$last_modified'"
    fi

    if [[ -z "$last_modified_by" ]]; then
        last_modified_by="NULL"
    fi

    # Connect to Oracle and insert the record
    sqlplus -S "${DB_USERNAME}/${DB_PASSWORD}@${DB_CONNECTION}" <<EOF
        INSERT INTO catissue_abstract_specimen (identifier, label, created_on, created_by, last_modified, last_modified_by)
        VALUES ($identifier, '$label', $created_on, $created_by, $last_modified, $last_modified_by);
EOF

    echo "Inserted record: identifier=$identifier, label=\"$label\", created_on=$created_on, created_by=$created_by, last_modified=$last_modified, last_modified_by=$last_modified_by"

    ((counter++))
    if (( counter % 100 == 0 )); then
        # Commit after every 100 records
        sqlplus -S "${DB_USERNAME}/${DB_PASSWORD}@${DB_CONNECTION}" <<EOF
            COMMIT;
EOF
    fi
done < "$CSV_FILE"

# Commit any remaining records
sqlplus -S "${DB_USERNAME}/${DB_PASSWORD}@${DB_CONNECTION}" <<EOF
    COMMIT;
EOF
