#/bin/bash

URL=http://localhost:8080/openspecimen/rest/ng
USERNAME=admin
PASSWORD=Test@123
FILE=cp_details.txt

exportCpDef() {
   for CP_ID in "${arr[@]}"
   do
     CP_DEF=$(curl -H "X-OS-API-TOKEN: $TOKEN" -X GET "$URL/collection-protocols/$CP_ID/definition")
     echo $CP_DEF > cpDef_$CP_ID.json
     CP_DEF=null;
   done

}

getAllCps() {
   if [ ! -z $TOKEN ]; then
      CP_DETAILS=$(curl -H "X-OS-API-TOKEN: $TOKEN" -X GET "$URL/collection-protocols")
      echo $CP_DETAILS > $FILE 
      arr=( $(jq -r '.[].id' $FILE) )
      printf '%s\n' "${arr[@]}"
   else 
      echo "Authentication is not done. Please enter correct username and password."
      exit 0;
   fi

}

authenticate() {
API_TOKEN=$(curl -u $USERNAME:$PASSWORD -X POST -H "Content-Type: application/json" -d '{"loginName":"'"$USERNAME"'","password":"'"$PASSWORD"'","domainName":"'"$DOMAIN_NAME"'"}' "$URL/sessions")
   TOKEN=$(echo $API_TOKEN | grep -o '"token":"[^"]*' | grep -o '[^"]*$')

}

main() {
  authenticate
  getAllCps
  exportCpDef
  rm $FILE

}

main;
