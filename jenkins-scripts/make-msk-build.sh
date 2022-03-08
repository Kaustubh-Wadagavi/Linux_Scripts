#!/bin/bash

source="/home/jenkins/jenkins_home/workspace/os_source/v6.0 Build"
destination=$1

if [ -z "$destination" ];then
  echo "Please specify the running job workspace to script."
  exit 1;
fi

#Retrieving latest RC build from v6.0 Build workspace.
cd "$source"
filename=`ls -t | head -1`
build_name=`find /home/jenkins/jenkins_home/workspace/os_source -name "$filename" | head -1`

#Checking if build exists or not.If it does not exist then script compresses only custom plugins with today's date.
if [ ! -e "$build_name" ];then
  echo "Build does not exist."
  cd "$destination"
  zip os-msk-build-`date '+%Y-%m-%d'`.zip zos-msk-*.jar os-hl7-*.jar 
  exit 1;
fi

#Extracting the latest RC build into WashU Build workspace for adding zos-msk.jar and os-hl7-*.jar to RC Build.
cd "$destination"
unzip "$build_name"
build=`echo "$filename" | cut -d'_' -f2 | cut -d'.' -f1,2,3`
cp zos-msk-*.jar "$build/plugin_build"
cp os-hl7-*.jar "$build/plugin_build"
zip -r os-msk-$build.zip $build
rm -r $build
