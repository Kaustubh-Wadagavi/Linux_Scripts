#!/bin/bash

sourceDir=$1
destination=$2

if [ -z "$destination" ];then
  echo "Please specify the running job workspace to script."
  exit 1;
fi

#Retrieving latest RC build from v7.1 Build workspace.
cd "$sourceDir"
filename=`ls -t | head -1`
build_name=`find /home/jenkins/jenkins_home/workspace/os_source -name "$filename" | head -1`

#Checking if build exists or not.If it does not exist then script compresses only custom plugins with today's date.
if [ ! -e "$build_name" ];then
  echo "Build does not exist."
  cd "$destination"
  zip os-cumc-build-`date '+%Y-%m-%d'`.zip os-easyblood-*.jar os-redcap-connector-*.jar os-edc-*.jar os-econsents-*.jar 
  exit 1;
fi

#Extracting the latest RC build into CUMC Build workspace for adding os-easyblood-*.jar and os-redcap-connector-*.jar to RC Build.
cd "$destination"
unzip "$build_name"
build=`echo "$filename" | cut -d'_' -f2 | cut -d'.' -f1,2,3`
cp os-easyblood-*.jar "$build/plugin_build"
cp os-redcap-connector-*.jar "$build/plugin_build"
cp os-edc-*.jar "$build/plugin_build"
cp os-econsents-*.jar "$build/plugin_build"
zip -r os-cumc-$build.zip $build

#Master build lines..
#unzip "$build_name" -d v6.2-build
#cp os-easyblood-*.jar "$destination/v6.2-build/plugin_build"
#cp os-redcap-connector-*.jar "$destination/v6.2-build/plugin_build"
#zip -r os-cumc-v6.2-build.zip v6.2-build
#rm -r v6.2-build
