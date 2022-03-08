#!/bin/bash

source="/home/jenkins/jenkins_home/workspace/os_source/master/"
destination=$1
appName=$2
buildDate=`date +%d-%m-%Y`

if [[ -z $destination ]]; then
  echo "Please specify the destination directory to copy master build."
  exit 1;
fi

if [[ -z $appName ]]; then
  appName="os-test";
fi

#if [ $appName == "os-econsents" ]; then
#  source="/home/jenkins/jenkins_home/workspace/os_source/Econsents Build"
#  todaysBuild=`ls -t1 "$source" |  head -1 | cut -d- -f3-5| cut -d. -f1`

  #This condition checks if the today's build did not find then take yesterday's build.
#  if [[ "$todaysBuild" != "$buildDate" ]]; then
#    buildDate=`date -d "$date -1 days" +"%d-%m-%Y"`
#  fi
#fi

#Getting latest file from the source directory.
cd "$source"
fileName=`ls -t1 | head -1 | cut -d- -f3-5| cut -d. -f1`
fileNameWithExtension=`ls -t1 | head -1`

if [[ $fileName == $buildDate ]]; then 
  cp $fileNameWithExtension "$destination"
  cd "$destination"
  unzip $fileNameWithExtension
  mv openspecimen.war "$appName.war"
else 
  echo "No zip file found of the current date"
  exit 1;
fi
