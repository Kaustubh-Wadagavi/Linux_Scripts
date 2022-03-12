#!/bin/bash

os_source=$1
base_folder=$2
config_file=$3
datestamp=$(date +%d-%m-%Y)

if [ -z $os_source ] || [ -z $base_folder ] || [ -z $config_file ]
then
    echo "Usage: ./master-zip-creation.sh <os_source folder path> <base_folder name> <list of jars>"
    exit 0;
fi

mkdir $base_folder-$datestamp $base_folder-$datestamp/plugin_build/

cp -r $os_source/build-tools/* $base_folder-$datestamp

cp $os_source/openspecimen/build/libs/openspecimen.war $base_folder-$datestamp
rm $workspace/os-extras/build/libs/os-extras.jar

while read plugin; do
   cp $os_source/$plugin/build/libs/*.jar $base_folder-$datestamp/plugin_build
done <$config_file

#Creating master build zip containing all required files.
zip -r $base_folder-$datestamp.zip $base_folder-$datestamp
rm -r $base_folder-$datestamp/
