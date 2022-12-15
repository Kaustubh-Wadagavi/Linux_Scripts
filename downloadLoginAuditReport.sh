#!/bin/bash

USERNAME=
PASSWORD=
URL=
FROM_DATE=
TO_DATE=

export() {

  curl -H "X-OS-API-TOKEN: $TOKEN" -H "Content-Type: application/zip" --request GET "$URL/rest/ng/login-audit-logs/report?domainName=openspecimen&fromDate=$FROM_DATE&toDate=$TO_DATE&users=" > login-audit-log.zip

}

getToken() {
  SESSIONS=$(curl -H "Content-Type: application/json" --request POST --data '{"loginName": "'"$USERNAME"'","password":"'"$PASSWORD"'","domainName":"'"openspecimen"'"}' "$URL/rest/ng/sessions")

  TOKEN=`echo ${SESSIONS} | jq -r '.token'`
}

getToken
export
