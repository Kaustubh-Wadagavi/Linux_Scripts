#!/bin/bash

Tag_Name=$1;
workspace=$2;

cd "$workspace/"
mkdir $Tag_Name
cd $Tag_Name
mkdir "$workspace/$Tag_Name/db-connectors"
mkdir "$workspace/$Tag_Name/apache"
cp /home/jenkins/jenkins_home/workspace/os_source/openspecimen_core/build/libs/*.war "$workspace/$Tag_Name"
cp /home/jenkins/jenkins_home/workspace/os_source/build-tools/install.sh "$workspace/$Tag_Name"
cp /home/jenkins/jenkins_home/workspace/os_source/build-tools/openspecimen.properties "$workspace/$Tag_Name"
cp /home/jenkins/jenkins_home/workspace/os_source/build-tools/install.bat "$workspace/$Tag_Name"
cp /home/jenkins/jenkins_home/workspace/os_source/db-connectors/*.jar "$workspace/$Tag_Name/db-connectors"
cp  /home/jenkins/jenkins_home/workspace/os_source/build-tools/Tomcat9.zip "$workspace/$Tag_Name"
cp /home/jenkins/jenkins_home/workspace/os_source/apache-config-files/httpd.conf "$workspace/$Tag_Name/apache/"
cp /home/jenkins/jenkins_home/workspace/os_source/apache-config-files/apache2.conf "$workspace/$Tag_Name/apache/"
cp /home/jenkins/jenkins_home/workspace/os_source/apache-config-files/downtime.html "$workspace/$Tag_Name/apache/"
cp /home/jenkins/jenkins_home/workspace/os_source/apache-config-files/os_logo_banner.png "$workspace/$Tag_Name/apache/"
mkdir plugin_build
cd plugin_build
cp /home/jenkins/jenkins_home/workspace/os_source/plugin_specimen-array/build/libs/*.jar "$workspace/$Tag_Name/plugin_build"
rm /home/jenkins/jenkins_home/workspace/os_source/plugin_os-extras/build/libs/plugin_os-extras.jar
cp /home/jenkins/jenkins_home/workspace/os_source/plugin_os-extras/build/libs/os-extras-6*.jar "$workspace/$Tag_Name/plugin_build"
cp /home/jenkins/jenkins_home/workspace/os_source/plugin_specimen-gel/build/libs/*.jar "$workspace/$Tag_Name/plugin_build"
cp /home/jenkins/jenkins_home/workspace/os_source/plugin_dashboard/build/libs/*.jar "$workspace/$Tag_Name/plugin_build"
cp /home/jenkins/jenkins_home/workspace/os_source/plugin_rde/build/libs/*.jar "$workspace/$Tag_Name/plugin_build"
cp /home/jenkins/jenkins_home/workspace/os_source/plugin_sde/build/libs/*.jar "$workspace/$Tag_Name/plugin_build"
cp /home/jenkins/jenkins_home/workspace/os_source/plugin_specimen-catalog/build/libs/*.jar "$workspace/$Tag_Name/plugin_build"
cp /home/jenkins/jenkins_home/workspace/os_source/plugin_distribution-invoicing/build/libs/*.jar "$workspace/$Tag_Name/plugin_build"
cd "$workspace/"
zip -r openspecimen_$Tag_Name.zip $Tag_Name
