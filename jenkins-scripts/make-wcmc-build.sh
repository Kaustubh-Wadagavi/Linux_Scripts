#!/bin/bash

sourceDir=$1
destination=$2

if [ -z "$destination" ];then
  echo "Please specify the running job workspace to script."
  exit 1;
fi

#Retrieving latest RC build from v6.0 Build workspace.
cd "$sourceDir"
filename=`ls -t | head -1`
build_name=`find /home/jenkins/jenkins_home/workspace/os_source -name "$filename" | head -1`

#Checking if build exists or not.If it does not exist then script compresses only custom plugins with today's date.
if [ ! -e "$build_name" ];then
  echo "Build does not exist."
  cd "$destination"
  zip os-wcmc-build-`date '+%Y-%m-%d'`.zip zos-wcmc-*.jar 
  exit 1;
fi

#Extracting the latest RC build and adding zos-wcmc.jar custom plugin to RC Build.
cd "$destination"
unzip "$build_name"
build=`echo "$filename" | cut -d'_' -f2 | cut -d'.' -f1,2,3`
cp zos-wcmc-*.jar "$build/plugin_build"
zip -r os-wcmc-$build.zip $build
