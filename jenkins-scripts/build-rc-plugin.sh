#!/bin/bash

bower_component_path="/home/jenkins/jenkins_home/workspace/os_source/openspecimen_core/www/bower_components"
bower_component="./src/main/webapp/bower_components"
node_module_path="/home/jenkins/jenkins_home/workspace/os_source/openspecimen_core/www/node_modules"
node_module="./src/main/webapp/node_modules"
external_module_path="/home/jenkins/jenkins_home/workspace/os_source/openspecimen_core/www/external_components"
external_module="./src/main/webapp/external_components"

OLD_TAG=$1
NEW_TAG=$2

git checkout master
git pull
if [ ! -z "$OLD_TAG" ]; then
  if [ ! -z "$NEW_TAG" ]; then
    echo "Old tag checking...";
    git tag | grep $OLD_TAG
    rc=$?;
    if [[ $rc == 1 ]]; then
	echo "$OLD_TAG tag not present on the repo."
	exit 1;
    fi
    git checkout $OLD_TAG
    git tag -a $NEW_TAG -m "OpenSpecimen release $NEW_TAG"
    git checkout $NEW_TAG
  else
    echo "Pass old tag and new tag to script as commandline argument..";
    exit 1;
  fi
fi
ln -sf $bower_component_path $bower_component
ln -sf $node_module_path $node_module
ln -sf $external_module_path $external_module
gradle clean
gradle build
