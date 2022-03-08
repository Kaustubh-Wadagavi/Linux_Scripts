#!/bin/bash

sourceDir=$1
destination=$2

if [ -z "$destination" ];then
  echo "Please specify the running job workspace to script."
  exit 1;
fi

#Retrieving latest RC build from v6.3 Build workspace.
cd "$sourceDir"
filename=`ls -t | head -1`
build_name=`find /home/jenkins/jenkins_home/workspace/os_source -name "$filename" | head -1`

#Checking if build exists or not.If it does not exist then script compresses only custom plugins with today's date.
if [ ! -e "$build_name" ];then
  echo "Build does not exist."
  cd "$destination"
  zip os-washu-build-`date '+%Y-%m-%d'`.zip zos-washu-*.jar os-redcap-connector-*.jar os-project-tracker-*.jar 
  exit 1;
fi

#Extracting the latest RC build into WashU Build workspace for adding zos-washu.jar and os-redcap-connector-*.jar to RC Build.
cd "$destination"
unzip "$build_name"
build=`echo "$filename" | cut -d'_' -f2 | cut -d'.' -f1,2,3`
cp zos-washu-*.jar "$build/plugin_build"
cp os-redcap-connector-*.jar "$build/plugin_build"
cp os-project-tracker-*.jar "$build/plugin_build"
zip -r os-washu-$build.zip $build
rm -r $build
