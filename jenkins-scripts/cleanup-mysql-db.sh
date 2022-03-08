#!/bin/bash

schemaName="os_mysql"

createMySQLDB() {
  echo "Checking if database is present or not...";
  mysql -u os_tester -p'secrete' -e "use ${schemaName};"
  result=$?;

  if [[ "$result" == "0" ]]; then
    echo "Dropping the existing database..."
    mysql -u os_tester -p'secrete' -e "drop database ${schemaName};"
    sleep 5;
  fi

  echo "Creating ${schemaName} database..."
  mysql -u os_tester -p'secrete' -e "create database ${schemaName}"
}

main(){
  createMySQLDB;
}
main;
