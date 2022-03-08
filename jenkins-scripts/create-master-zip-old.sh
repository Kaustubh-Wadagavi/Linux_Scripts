#!/bin/bash

workspace="/home/jenkins/jenkins_home/workspace/os_source"
#Store current date in a variable 
datestamp=$(date +%d-%m-%Y)

#Create a directory with name as current date
mkdir v7.1-build-$datestamp v7.1-build-$datestamp/apache v7.1-build-$datestamp/db-connectors 

#Create a directory inside the previous directory to store all the plugins
cd v7.1-build-$datestamp

#Copy the war files in the new director
cp $workspace/openspecimen/build/libs/openspecimen.war .
cp /home/jenkins/jenkins_home/workspace/os_source/build-tools/install.sh .
cp /home/jenkins/jenkins_home/workspace/os_source/build-tools/openspecimen.properties .
cp /home/jenkins/jenkins_home/workspace/os_source/build-tools/install.bat .
cp /home/jenkins/jenkins_home/workspace/os_source/apache-config-files/* ./apache
cp /home/jenkins/jenkins_home/workspace/os_source/db-connectors/* ./db-connectors
cp /home/jenkins/jenkins_home/workspace/os_source/build-tools/tomcat-as.zip .

#Create a directory to store plugins
mkdir plugin_build

#Copy all jars to the new directory
cp $workspace/specimen-array/build/libs/*.jar ./plugin_build
rm $workspace/os-extras/build/libs/os-extras.jar
cp $workspace/os-extras/build/libs/*.jar ./plugin_build
cp $workspace/specimen-gel/build/libs/*.jar ./plugin_build
cp $workspace/dashboard/build/libs/*.jar ./plugin_build
cp $workspace/rde/build/libs/*.jar ./plugin_build
cp $workspace/sde/build/libs/*.jar ./plugin_build
cp $workspace/specimen-catalog/build/libs/*.jar ./plugin_build
cp $workspace/distribution-invoicing/build/libs/*.jar ./plugin_build

cd $workspace/Create\ Master\ Build/v7.1-build-$datestamp

#Creating master build zip containing all required files.
zip -r v7.1-build-$datestamp.zip install.sh apache db-connectors openspecimen.properties openspecimen.war install.bat  plugin_build/
mv v7.1-build-$datestamp.zip $workspace/Create\ Master\ Build/

rm -r $workspace/Create\ Master\ Build/v7.1-build-$datestamp

