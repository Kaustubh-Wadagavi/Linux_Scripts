#!/bin/bash

workspace=$1
base_folder=$2
datestamp=$(date +%d-%m-%Y)

mkdir $base_folder-$datestamp

cp -r $workspace/build-tools/* $base_folder-$datestamp
mkdir $base_folder-$datestamp/plugin_build/

cp $workspace/openspecimen/build/libs/openspecimen.war $base_folder-$datestamp
cp $workspace/specimen-array/build/libs/*.jar $base_folder-$datestamp/plugin_build
rm $workspace/os-extras/build/libs/os-extras.jar
cp $workspace/os-extras/build/libs/*.jar $base_folder-$datestamp/plugin_build
cp $workspace/specimen-gel/build/libs/*.jar $base_folder-$datestamp/plugin_build
cp $workspace/dashboard/build/libs/*.jar $base_folder-$datestamp/plugin_build
cp $workspace/rde/build/libs/*.jar $base_folder-$datestamp/plugin_build
cp $workspace/sde/build/libs/*.jar $base_folder-$datestamp/plugin_build
cp $workspace/specimen-catalog/build/libs/*.jar $base_folder-$datestamp/plugin_build
cp $workspace/distribution-invoicing/build/libs/*.jar $base_folder-$datestamp/plugin_build

#Creating master build zip containing all required files.
zip -r $base_folder-$datestamp.zip $base_folder-$datestamp
rm -r $base_folder-$datestamp/
