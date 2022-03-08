#!/bin/bash

#sourceDir="/home/jenkins/jenkins_home/workspace/os_source/Release Build"
#destination="/home/jenkins/jenkins_home/workspace/os_source/Demo-Site-Deploy"

sourceDir=$1
destination=$2

if [ -d "$destination" ]; then
   [ "$(ls -A "$destination" )" ] && echo $(rm -r "$destination"/*)
fi

if [ -d "$sourceDir" ] && [ -d "$destination" ]
then
   unzip "$sourceDir/openspecimen_*.zip" -d "$destination"
   mv "$destination"/v*/* "$destination"
   unzip "$sourceDir/os-tracker-*.zip" -d "$destination/plugin_build/"
   unzip "$sourceDir/os-starter-kit-*.zip" -d "$destination/plugin_build/"
   unzip "$sourceDir/os-edc-*.zip" -d "$destination/plugin_build/"
   unzip "$sourceDir/os-supplies-*.zip" -d "$destination/plugin_build/"
else
   echo "Please pass command line arguments with script 1. sourceDir 2. destination"
fi

