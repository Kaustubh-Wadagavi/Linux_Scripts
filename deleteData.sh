#!/bin/bash

CONFIG_FILE=$1

deleteData()
{
  while IFS="," read -r ID CP
  do
    #echo "$REQUEST_URL$ID"
    curl -u $USERNAME:$PASSWORD --header "Content-Type: application/json" --request DELETE "$REQUEST_URL$ID"
  done < <(tail -n +2 $INPUT_FILE)
}

if [ -f "$CONFIG_FILE" ]
then
    source $CONFIG_FILE
    deleteData
else
    echo "Please input the config file"
    exit 1;
fi
