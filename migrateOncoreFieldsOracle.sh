#!/bin/bash

DB_USER=OPENSPECIMEN_DEV
DB_PASS=OPSPMN
DB_CONNECTION=""
LOG_FILE="error_log.csv"

execute_sql() {
    sqlplus -S "$DB_USER/$DB_PASS@$DB_CONNECTION" @$1
}

migrateFormsData() {
    MAX_ID_SQL="SELECT MAX(IDENTIFIER) FROM DE_E_11076;"
    MAX_ID=$(execute_sql "get_max_id.sql" | tail -n 1)

    counter=0
    echo "SET AUTOCOMMIT OFF;" >> "batch.sql"
    while IFS=, read -r IDENTIFIER EXT_SUB_ID DE_A_1 DE_A_2 DE_A_3; do
        REG_CHECK_SQL="SELECT COUNT(*) FROM CATISSUE_COLL_PROT_REG WHERE IDENTIFIER=$IDENTIFIER;"
        REG_COUNT=$(execute_sql "check_registration.sql $IDENTIFIER" | tail -n 1)

        if [ "$REG_COUNT" -eq 0 ]; then
            echo "$IDENTIFIER,$EXT_SUB_ID,$DE_A_1,$DE_A_2,$DE_A_3" >> "$LOG_FILE"
            echo "Error: Registration with IDENTIFIER=$IDENTIFIER does not exist. Row logged into $LOG_FILE."
            continue
        fi

        MAX_ID=$((MAX_ID + 1))
        cleaned_DE_A_2=$(echo "$DE_A_2" | sed 's/"//g')
        REG_UPDATE_SQL="UPDATE CATISSUE_COLL_PROT_REG SET EXTERNAL_SUBJECT_ID='$EXT_SUB_ID' WHERE IDENTIFIER=$IDENTIFIER;"
        DE_TABLE_INSERT="INSERT INTO DE_E_11076(IDENTIFIER, DE_A_1, DE_A_2, DE_A_3) VALUES ($MAX_ID, '$DE_A_1', '$cleaned_DE_A_2', '$DE_A_3');"
        CATISSUE_FORM_REC_ENTRY_SQL="INSERT INTO CATISSUE_FORM_RECORD_ENTRY(FORM_CTXT_ID, OBJECT_ID, RECORD_ID, UPDATED_BY, UPDATE_TIME, ACTIVITY_STATUS, FORM_STATUS, OLD_OBJECT_ID) VALUES (63, $IDENTIFIER, $MAX_ID, 2, SYSDATE, 'ACTIVE', 'COMPLETE', NULL);"

        echo "$REG_UPDATE_SQL" >> "batch.sql"
        echo "$DE_TABLE_INSERT" >> "batch.sql"
        echo "$CATISSUE_FORM_REC_ENTRY_SQL" >> "batch.sql"

        counter=$((counter + 1))
        if ((counter % 100 == 0)); then
            echo "commit;" >> "batch.sql"
	    execute_sql "batch.sql"
            rm "batch.sql"
        fi
    done < <(tail -n +2 "$1")

}

main() {
    if [ $# -lt 1 ]; then
        echo "Error: Missing arguments."
        echo "Usage: $0 <input_file.csv>"
        exit 1
    fi

    inputFile=$1

    # Check if inputFile is a valid file
    if [ ! -f "$inputFile" ]; then
        echo "Error: $inputFile is not a valid file."
        exit 1
    fi

    migrateFormsData "$inputFile"
}

main "$@"

