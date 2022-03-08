#!/bin/bash

workspace="/home/jenkins/jenkins_home/workspace/os_source"

#Store current date in a variable 
datestamp=$(date +%d-%m-%Y)

#Create a directory with name as current date
mkdir v6.3-build-$datestamp v6.3-build-$datestamp/apache v6.3-build-$datestamp/db-connectors 

#Create a directory inside the previous directory to store all the plugins
cd v6.3-build-$datestamp

#Copy the war files in the new director
cp $workspace/openspecimen/build/libs/*.war .
cp /home/jenkins/jenkins_home/workspace/os_source/build-tools/install.sh .
cp /home/jenkins/jenkins_home/workspace/os_source/build-tools/openspecimen.properties .
cp /home/jenkins/jenkins_home/workspace/os_source/build-tools/install.bat .
cp /home/jenkins/jenkins_home/workspace/os_source/apache-config-files/* ./apache
cp /home/jenkins/jenkins_home/workspace/os_source/db-connectors/* ./db-connectors

#Create a directory to store plugins
mkdir plugin_build

cd plugin_build

#Copy all jars to the new directory
cp $workspace/specimen-array/build/libs/*.jar .
rm $workspace/os-extras/build/libs/os-extras.jar
cp $workspace/os-extras/build/libs/*.jar .
cp $workspace/specimen-gel/build/libs/*.jar .
cp $workspace/dashboard/build/libs/*.jar .
cp $workspace/rde/build/libs/*.jar .
cp $workspace/sde/build/libs/*.jar .
cp $workspace/specimen-catalog/build/libs/*.jar .
cp $workspace/distribution-invoicing/build/libs/*.jar .

cd $workspace/Create\ Master\ Build/v6.3-build-$datestamp

#Create a zip of the new directory which has all the jars and wars
zip -r v6.3-build-$datestamp.zip install.sh apache db-connectors openspecimen.properties openspecimen.war install.bat  plugin_build/
mv v6.3-build-$datestamp.zip ..

cd ..
rm -r v6.3-build-$datestamp
