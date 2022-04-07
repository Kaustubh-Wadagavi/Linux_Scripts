#!/bin/bash

appurl="https://test.openspecimen.org/os-test"
appPropPath="/home/jenkins/jenkins_home/workspace/os_source/jenkins_script/"

cd "$appPropPath"
rm "$appPropPath/app-props"
wget --no-check-certificate $appurl/rest/ng/config-settings/app-props
build_timestamp=$(grep -o -P '\"build_date\":.{14}' "$appPropPath/app-props" | sed 's/"//g' | cut -d':' -f2)
ostest_build_date=$(date -d @$(($build_timestamp/1000)) +'%Y-%m-%d')
