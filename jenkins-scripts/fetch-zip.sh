#!/bin/bash

source="/home/jenkins/jenkins_home/workspace/os_source/Create Master Build/"
destination="/home/jenkins/jenkins_home/workspace/os_source/Nightly Deploy Master Build (os-test)/"

cd "$source"
fileName=`ls -t1 | head -1 | cut -d- -f3-5| cut -d. -f1`
currentDate=`date +%d-%m-%Y`
fileNameWithExtension=`ls -t1 | head -1`

if [[ $fileName == $currentDate ]]; then 
  cp $fileNameWithExtension "$destination"
  cd "$destination"
  unzip $fileNameWithExtension
  mv openspecimen.war os-test.war
else 
  echo "No zip file found of the current date"
  exit 1
fi
