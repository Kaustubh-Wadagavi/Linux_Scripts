#!/bin/bash

destination=$1
source_dir="/home/jenkins/jenkins_home/workspace/os_source/Create Master Build"
consent_plugin_dir="/home/jenkins/jenkins_home/workspace/os_source/econsents"
datestamp=$(date +%d-%m-%Y)
latestbuild=$(ls -t "$source_dir" | head -1)

rc=$?;
if [[ $rc != 0 ]]; then
  echo "Error: Could not find the master build to copy. Please check if specified source directory($source_dir) is correct or not.";
  exit $rc;
fi

if [[ -z $destination ]]; then
  echo "Please specify the destination directory to copy econsent build."
  exit 1;
fi

cp "$source_dir/$latestbuild" "$destination"
cd "$destination"
unzip $latestbuild
echo "Adding the plugin into the build."
cp $consent_plugin_dir/build/libs/os-econsents-*.jar "$destination/plugin_build/"
zip -r v7.0-build-$datestamp.zip install.sh apache db-connectors openspecimen.properties openspecimen.war install.bat  plugin_build/
rm -r install.sh apache db-connectors openspecimen.properties openspecimen.war install.bat plugin_build/
