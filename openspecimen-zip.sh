#!/bin/bash

os_source=$1
base_folder=$2
config_file=$3
datestamp=$(date +%d-%m-%Y)

if [ -z $os_source ] || [ -z $base_folder ] || [ -z $config_file ]
then
    echo "Usage: ./openspecimen-zip.sh <os_source folder path> <base_folder name> <list of jars>"
    exit 0;
fi

mkdir $base_folder-$datestamp $base_folder-$datestamp/plugin_build/

cp -r $os_source/build-tools/* $base_folder-$datestamp

cp $os_source/openspecimen/build/libs/openspecimen.war $base_folder-$datestamp

while IFS=, read -r plugin plugin_file_name; do
  if [ -f $os_source/$os_source/$plugin/build/libs/$plugin_file_name ]
  then
    cp $os_source/$plugin/build/libs/$plugin_file_name $base_folder-$datestamp/plugin_build
  else
    echo "Plugin not found"
    exit 0;
  fi  
done <$config_file

#Creating master build zip containing all required files.
zip -r $base_folder-$datestamp.zip $base_folder-$datestamp
rm -r $base_folder-$datestamp/
