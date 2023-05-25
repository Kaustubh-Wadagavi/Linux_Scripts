#!/bin/bash

# Define variables
CSV_FILE="test.csv"
DB_USERNAME=
DB_PASSWORD=
DB_CONNECTION=

# Read CSV file and update records
while IFS=',' read -r identifier short_title
do
    # Connect to Oracle and update the record
    sqlplus -S "${DB_USERNAME}/${DB_PASSWORD}@${DB_CONNECTION}" <<EOF
        UPDATE catissue_collection_protocol
        SET short_title='$short_title'
        WHERE identifier='$identifier';
        COMMIT;
        EXIT;
EOF

    echo "Updated record: identifier=$identifier, short_title=$short_title"
done < "$CSV_FILE"
