#!/bin/bash

userName=
token=
url=
currentTime=$(date "+%Y.%m.%d-%H.%M.%S")

createCSV() {
  totalIssues=$(cat issues.json | jq '.total')
  echo '"Ticket No.","Ticket Summary","Resolution Status","Reporting Center"' >> jira-support-issues-$currentTime.csv
  for (( c=0; c<$totalIssues; c++ ))
  do
    key=$(cat issues.json | jq '.issues['$c'].key')
    summary=$(cat issues.json | jq '.issues['$c'].fields.summary')
    issueStatus=$(cat issues.json | jq '.issues['$c'].fields.status.name')
    security=$(cat issues.json | jq '.issues['$c'].fields.security.description')
    echo "$key","$summary","$issueStatus","$security" >> jira-support-issues-$currentTime.csv
  done
  rm issues.json
}

getIssues() {
  curl -X GET -H "Content-Type: application/json"  "https://openspecimen.atlassian.net/rest/api/3/search?jql=filter=18721" --user $userName:$token > issues.json
}

getIssues
createCSV
