#!/bin/bash

workspace="/home/jenkins/jenkins_home/workspace/os_source"

#Store current date in a variable 
datestamp=$(date +%d-%m-%Y)

#Create a directory with name as current date
mkdir pv-build-$datestamp pv-build-$datestamp/apache pv-build-$datestamp/db-connectors 

#Create a directory inside the previous directory to store all the plugins
cd pv-build-$datestamp

#Copy the war files in the new directory
cp $workspace/OpenSpecimen_Core/build/libs/*.war .
cp /home/jenkins/jenkins_home/workspace/os_source/build-tools/install.sh .
cp /home/jenkins/jenkins_home/workspace/os_source/build-tools/openspecimen.properties .
cp /home/jenkins/jenkins_home/workspace/os_source/build-tools/install.bat .
cp /home/jenkins/jenkins_home/workspace/os_source/apache-config-files/* ./apache
cp /home/jenkins/jenkins_home/workspace/os_source/db-connectors/* ./db-connectors

#Create a directory to store plugins
mkdir plugin_build

cd plugin_build

#Copy all jars to the new directory
cp $workspace/plugin_specimen-array/build/libs/*.jar .
rm $workspace/plugin_os-extras/build/libs/plugin_os-extras.jar
cp $workspace/plugin_os-extras/build/libs/*.jar .
cp $workspace/plugin_specimen-gel/build/libs/*.jar .
cp $workspace/plugin_dashboard/build/libs/*.jar .
cp $workspace/plugin_rde/build/libs/*.jar .
cp $workspace/plugin_sde/build/libs/*.jar .
cp $workspace/plugin_specimen-catalog/build/libs/*.jar .
cp $workspace/plugin_distribution-invoicing/build/libs/*.jar .

cd $workspace/PV_Manager_Build/pv-build-$datestamp

#Create a zip of the new directory which has all the jars and wars
zip -r pv-build-$datestamp.zip install.sh apache db-connectors openspecimen.properties openspecimen.war install.bat  plugin_build/
mv pv-build-$datestamp.zip ..

cd ..
rm -r pv-build-$datestamp
