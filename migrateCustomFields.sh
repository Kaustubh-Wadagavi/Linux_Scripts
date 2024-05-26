DB_USER=root
DB_PASS=secrete
DB_STRING=
DB_NAME=v103rc4

migrateFormsData() {
   mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SET autocommit=0;"
   MAX_ID_SQL="SELECT MAX(IDENTIFIER) FROM DE_E_11076;"
   MAX_ID=$(mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -se "$MAX_ID_SQL")
   
   counter=0
   tail -n +2 "$inputFile" | while IFS=, read -r IDENTIFIER EXT_SUB_ID DE_A_1 DE_A_2 DE_A_3
   do
     MAX_ID=$((MAX_ID + 1))
     cleaned_DE_A_2=$(echo "$DE_A_2" | sed 's/"//g')
     REG_UPDATE_SQL="UPDATE CATISSUE_COLL_PROT_REG SET EXTERNAL_SUBJECT_ID='$EXT_SUB_ID' WHERE IDENTIFIER=$IDENTIFIER";
     DE_TABLE_INSERT="INSERT INTO DE_E_11076(IDENTIFIER, DE_A_1, DE_A_2, DE_A_3) VALUES ($MAX_ID, '$DE_A_1', '$cleaned_DE_A_2', '$DE_A_3');"
     CATISSUE_FORM_REC_ENTRY_SQL="INSERT INTO CATISSUE_FORM_RECORD_ENTRY(FORM_CTXT_ID, OBJECT_ID, RECORD_ID, UPDATED_BY, UPDATE_TIME, ACTIVITY_STATUS, FORM_STATUS, OLD_OBJECT_ID) VALUES (41,$IDENTIFIER, $MAX_ID, 2, Now(), 'ACTIVE', 'COMPLETE', null);"
     
     mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "$REG_UPDATE_SQL"
     mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "$DE_TABLE_INSERT"
     mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "$CATISSUE_FORM_REC_ENTRY_SQL"

     counter=$((counter + 1))
     if ((counter % 100 == 0)); then
       mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "COMMIT;"
     fi
  done

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
