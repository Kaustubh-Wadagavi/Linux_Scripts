#!/bin/bash

bower_component_path="/home/jenkins/jenkins_home/workspace/os_source/openspecimen/www/bower_components"
bower_component="./src/main/webapp/bower_components"
node_module_path="/home/jenkins/jenkins_home/workspace/os_source/openspecimen/www/node_modules"
node_module="./src/main/webapp/node_modules"
external_module_path="/home/jenkins/jenkins_home/workspace/os_source/openspecimen/www/external_components"
external_module="./src/main/webapp/external_components"
ui_node_modules_path="/home/jenkins/jenkins_home/workspace/os_source/openspecimen/ui/node_modules"
ui_node_modules="./src/main/ui/node_modules"

repo_dir=$1
branch_name=$2
release_name=$3

if [ -z $branch_name ] || [ ! -d $repo_dir ]
then
   echo "Usage: ./build-custom-plugin.sh <repo_dir> <branch_name> <release_name>"
   echo "Pass repo_dir,branch_name and release_name to script as commandline argument..";
   exit 1;
fi

cd $repo_dir
git pull
git checkout $branch_name

if [  -z "$release_name" ]; then
    git tag -a $release_name -m "OpenSpecimen release $release_name"
    git checkout $NEW_TAG
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
