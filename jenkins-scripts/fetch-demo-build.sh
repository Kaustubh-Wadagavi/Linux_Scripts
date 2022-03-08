#!/bin/bash

sourceDir=$1
destination=$2

if [ -z "$destination" ];then
  echo "Please specify the running job workspace to script."
  exit 1;
fi

#Retrieving latest RC build from v7.0 Build workspace.
cd "$sourceDir"
filename=`ls -t | head -1`
build_name=`find /home/jenkins/jenkins_home/workspace/os_source -name "$filename" | head -1`

cd "$destination"
unzip "$build_name"

#Retrive tag name.
build=`echo "$filename" | cut -d'_' -f2 | cut -d'.' -f1,2,3`

mv $build/* "$destination"

