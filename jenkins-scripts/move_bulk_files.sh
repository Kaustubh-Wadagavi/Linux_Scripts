#!/bin/bash

sourceDir="/home/jenkins/jenkins_home/workspace/os_source/build-tools/Automated_testing_BO/"
targetDir=$1 #Takes target workspace is input to the script.

if [[ -z $targetDir ]]; then
  echo "Please specify the destination directory to copy master build."
  exit 1;
fi

echo "Pulling latest BO files from bitbucket repo."
mkdir "$targetDir/bulk-import"
cd $sourceDir
git checkout master
git pull

echo "Copyting the BO files to target workspace for transferring it to os-test instance."
cp $sourceDir/cp*.csv "$targetDir/bulk-import" 
cp $sourceDir/site.csv "$targetDir/bulk-import"  
cp $sourceDir/user.csv "$targetDir/bulk-import"
cp $sourceDir/userRoles.csv "$targetDir/bulk-import"
cp $sourceDir/institute.csv "$targetDir/bulk-import"
