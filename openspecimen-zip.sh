#!/bin/bash

os_source=$1
base_folder=$2
release_name=$3
config_file=$4
datestamp=$(date +%d-%m-%Y)

if [ -z $os_source ] || [ -z $base_folder ] || [ -z $config_file ] || [ -z realese_name ]
then
    echo "Usage: ./master-zip-creation.sh <os_source folder path> <base_folder name> <realese_name> <list of jars>"
    exit 1;
fi

mkdir $base_folder-$datestamp $base_folder-$datestamp/plugin_build/

cp -r $os_source/build-tools/* $base_folder-$datestamp

cp $os_source/openspecimen/build/libs/openspecimen.war $base_folder-$datestamp

while IFS=, read -r plugin plugin_file_name; do
  if [ -f "$os_source/$plugin/build/libs/$plugin_file_name-$release_name.jar" ]
  then
    cp $os_source/$plugin/build/libs/$plugin_file_name-$release_name.jar $base_folder-$datestamp/plugin_build
  else
    echo $plugin_file_name
    echo "Plugin not found"
    exit 1;
  fi  
done <$config_file

#Creating master build zip containing all required files.
if [ ! -z $release_name ] && [ $release_name == "master" ]
then 	
   if [ -f $base_folder-$datestamp.zip ];then
      echo "deleting existing file"
      rm $base_folder-$datestamp.zip
   fi
   zip -r $base_folder-$datestamp.zip $base_folder-$datestamp
   rm -r $base_folder-$datestamp/
else
   zip -r $base_folder.zip $base_folder-$datestamp
   cp $base_folder.zip /home/jenkins/jenkins_home/workspace/os_source/OpenSpecimen\ Downloads/
fi
