#!/bin/bash

tag_name=$1
workspace=$2

if [ -z "$tag_name" ]
then
  echo "Please specify the tag name to Job.";
  exit 1;
fi

if [ -z "$workspace" ]
then
  echo "Please specify the running job workspace to Job."
  exit 1;
fi

build_name=`find /home/jenkins/jenkins_home/workspace/os_source -name "openspecimen_$tag_name.zip" | head -1`

if [ ! -e "$build_name" ]
then
  echo "Build with specified $Tag_Name does not exist."
  exit 1;
fi

cd "$workspace"
unzip "$build_name"

cp "$tag_name/openspecimen.war" .
cp -r "$tag_name/plugin_build" ./plugins

cp -r /home/jenkins/jenkins_home/workspace/os_source/docker/linux/* "$workspace"
