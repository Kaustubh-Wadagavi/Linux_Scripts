#!/bin/bash

USERNAME="kaustubh@krishagni.com"
PASSWORD="Login@123"
URL="https://demo.openspecimen.org/"
FROM_DATE=2022-12-12
TO_DATE=2022-12-15

export() {

  curl -H "X-OS-API-TOKEN: $TOKEN" -H "Content-Type: application/zip" --request GET "$URL/rest/ng/login-audit-logs/report?domainName=openspecimen&fromDate=$FROM_DATE&toDate=$TO_DATE&users=" > login-audit-log.zip

}

getToken() {
  SESSIONS=$(curl -H "Content-Type: application/json" --request POST --data '{"loginName": "'"$USERNAME"'","password":"'"$PASSWORD"'","domainName":"'"openspecimen"'"}' "$URL/rest/ng/sessions")

  TOKEN=`echo ${SESSIONS} | jq -r '.token'`
}

getToken
export
