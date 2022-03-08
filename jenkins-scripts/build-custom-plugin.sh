#!/bin/bash

bower_component_path="/home/jenkins/jenkins_home/workspace/os_source/openspecimen/www/bower_components"
bower_component="./src/main/webapp/bower_components"
node_module_path="/home/jenkins/jenkins_home/workspace/os_source/openspecimen/www/node_modules"
node_module="./src/main/webapp/node_modules"
external_module_path="/home/jenkins/jenkins_home/workspace/os_source/openspecimen/www/external_components"
external_module="./src/main/webapp/external_components"
ui_node_modules_path="/home/jenkins/jenkins_home/workspace/os_source/openspecimen/ui/node_modules"
ui_node_modules="./src/main/ui/node_modules"

OLD_TAG=$1
NEW_TAG=$2

git checkout master
git pull
if [ ! -z "$OLD_TAG" ]; then
  if [ ! -z "$NEW_TAG" ]; then
    git checkout $OLD_TAG
    git pull
    git tag -a $NEW_TAG -m "OpenSpecimen release $NEW_TAG"
    git checkout $NEW_TAG
  else
    echo "Usage: ./build-custom-plugin.sh <OLD-TAG> <NEW-TAG>"
    echo "Pass old tag and new tag to script as commandline argument..";
    exit 1;
  fi
fi

ln -sf $bower_component_path $bower_component
ln -sf $node_module_path $node_module
ln -sf $external_module_path $external_module

if [ -d "./src/main/ui" ]
then
  ln -sf $ui_node_modules_path $ui_node_modules
fi

gradle clean
gradle build
