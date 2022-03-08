#!/bin/bash

bower_component_path="/home/jenkins/jenkins_home/workspace/os_source/openspecimen/www/bower_components"
bower_component="./src/main/webapp/bower_components"
node_module_path="/home/jenkins/jenkins_home/workspace/os_source/openspecimen/www/node_modules"
node_module="./src/main/webapp/node_modules"
external_module_path="/home/jenkins/jenkins_home/workspace/os_source/openspecimen/www/external_components"
external_module="./src/main/webapp/external_components"
Tag_Name=$1

git checkout master
git pull

if [ ! -z "$Tag_Name" ]
then
  git tag -a $Tag_Name -m "OpenSpecimen release $Tag_Name"
  git checkout $Tag_Name
fi

ln -sf $bower_component_path $bower_component
ln -sf $node_module_path $node_module
ln -sf $external_module_path $external_module
gradle clean
gradle build
git checkout master
