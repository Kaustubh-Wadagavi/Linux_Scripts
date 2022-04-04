#!/bin/bash 

os_source=$1
release_name=$2
config_file=$3

if [ ! -d $os_source ] || [ ! -z $relase_name ] || [ ! -f $config_file ]
then
    echo "Usage: ./zip-paid-plugins.sh <source dir> <release_name> <config_file_path>"
    exit 1;
fi

while IFS=, read -r plugin plugin_file_name; do
  if [ -f "$os_source/$plugin/build/libs/$plugin_file_name-$release_name.jar" ]
  then
    cp $os_source/$plugin/build/libs/$plugin_file_name-$release_name.jar .
    zip -r $plugin_file_name-$release_name $plugin_file_name-$release_name.jar
    rm $plugin_file_name-$release_name.jar
    cp os-$plugin-$release_name.zip /usr/local/jenkins/openspecimen-plugins
  else
    echo $plugin_file_name
    echo "Plugin not found"
    exit 1;
  fi
done <$config_file
