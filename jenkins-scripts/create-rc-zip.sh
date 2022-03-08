#!/bin/bash

tag_name=$1;
workspace=$2;

if [[ -z $tag_name ]]; then 
  echo "Error: Please specify the tag name."
  echo "Usage: ./create-rc-zip.sh <new-tag> <destination>"
  exit 1;
fi

if [[ -z $workspace ]]; then
  echo "Error: Please specify the destination directory to copy RC build."
  echo "Usage: ./create-rc-zip.sh <new-tag> <destination>"
  exit 1;
fi

cd "$workspace/"
mkdir $tag_name
cd $tag_name
mkdir "$workspace/$tag_name/db-connectors"
mkdir "$workspace/$tag_name/apache"
cp /home/jenkins/jenkins_home/workspace/os_source/openspecimen_core/build/libs/*.war "$workspace/$tag_name"
cp /home/jenkins/jenkins_home/workspace/os_source/build-tools/install.sh "$workspace/$tag_name"
cp /home/jenkins/jenkins_home/workspace/os_source/build-tools/openspecimen.properties "$workspace/$tag_name"
cp /home/jenkins/jenkins_home/workspace/os_source/build-tools/install.bat "$workspace/$tag_name"
cp /home/jenkins/jenkins_home/workspace/os_source/db-connectors/*.jar "$workspace/$tag_name/db-connectors"
cp  /home/jenkins/jenkins_home/workspace/os_source/build-tools/Tomcat9.zip "$workspace/$tag_name"
cp /home/jenkins/jenkins_home/workspace/os_source/apache-config-files/httpd.conf "$workspace/$tag_name/apache/"
cp /home/jenkins/jenkins_home/workspace/os_source/apache-config-files/apache2.conf "$workspace/$tag_name/apache/"
cp /home/jenkins/jenkins_home/workspace/os_source/apache-config-files/downtime.html "$workspace/$tag_name/apache/"
cp /home/jenkins/jenkins_home/workspace/os_source/apache-config-files/os_logo_banner.png "$workspace/$tag_name/apache/"
mkdir plugin_build
cp /home/jenkins/jenkins_home/workspace/os_source/plugin_specimen-array/build/libs/*.jar "$workspace/$tag_name/plugin_build"
rm /home/jenkins/jenkins_home/workspace/os_source/plugin_os-extras/build/libs/plugin_os-extras.jar
cp /home/jenkins/jenkins_home/workspace/os_source/plugin_os-extras/build/libs/os-extras-*.jar "$workspace/$tag_name/plugin_build"
cp /home/jenkins/jenkins_home/workspace/os_source/plugin_specimen-gel/build/libs/*.jar "$workspace/$tag_name/plugin_build"
cp /home/jenkins/jenkins_home/workspace/os_source/plugin_dashboard/build/libs/*.jar "$workspace/$tag_name/plugin_build"
cp /home/jenkins/jenkins_home/workspace/os_source/plugin_rde/build/libs/*.jar "$workspace/$tag_name/plugin_build"
cp /home/jenkins/jenkins_home/workspace/os_source/plugin_sde/build/libs/*.jar "$workspace/$tag_name/plugin_build"
cp /home/jenkins/jenkins_home/workspace/os_source/plugin_specimen-catalog/build/libs/*.jar "$workspace/$tag_name/plugin_build"
cp /home/jenkins/jenkins_home/workspace/os_source/plugin_distribution-invoicing/build/libs/*.jar "$workspace/$tag_name/plugin_build"
cd "$workspace/"
zip -r openspecimen_$tag_name.zip $tag_name
