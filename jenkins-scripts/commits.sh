#!/bin/bash

appurl="https://test.openspecimen.org/os-test"
appPropPath="/home/jenkins/jenkins_home/workspace/os_source/jenkins_script/"

cd "$appPropPath"
rm "$appPropPath/app-props"
wget $appurl/rest/ng/config-settings/app-props
build_timestamp=$(grep -o -P '\"build_date\":.{14}' "$appPropPath/app-props" | sed 's/"//g' | cut -d':' -f2)
ostest_build_date=$(date -d @$(($build_timestamp/1000)) +'%Y-%m-%d')

if [[ -z $ostest_build_date ]]; then
  ostest_build_date=$(date +%Y-%m-%d)
fi

cd /home/jenkins/jenkins_home/workspace/os_source/openspecimen
git log --after="$ostest_build_date 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/dashboard
git log --after="$ostest_build_date 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/distribution-invoicing
git log --after="$ostest_build_date 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/os-extras
git log --after="$ostest_build_date 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/rde
git log --after="$ostest_build_date 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/sde
git log --after="$ostest_build_date 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/specimen-array
git log --after="$ostest_build_date 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/specimen-catalog
git log --after="$ostest_build_date 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/specimen-gel
git log --after="$ostest_build_date 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/edc
git log --after="$ostest_build_date 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/econsents
git log --after="$ostest_build_date 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/redcap-connector
git log --after="$ostest_build_date 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/oc-connector
git log --after="$ostest_build_date 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/tracker
git log --after="$ostest_build_date 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/supplies
git log --after="$ostest_build_date 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/os-mobile-plugin
git log --after="$ostest_build_date 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

mv /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt /home/jenkins/jenkins_home/workspace/os_source/Check\ Test\ Server\ Status/
