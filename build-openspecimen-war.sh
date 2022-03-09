#!/bin/bash

branch_name=$1
release_name=$2
master_dir="/mnt/volume_nyc1_01/new_workspace/os_source/openspecimen"

if [ -z $branch_name ]
then
   echo "1. If you releasing only master build the please provide only master branch name with command line"
   echo "2. If you releasing the version the please provide a. branch name b. release name with command line"
   exit 0;
fi

npm cache clean --force
/home/jenkins/jenkins_home/workspace/os_source/jenkins_script/remove-links.sh

cd $master_dir

exists=`git ls-remote --heads origin $branch_name`
if [ ! -n "$exists" ]
then
   echo "branch doesn't exist"
   exit 0;
fi

git checkout $branch_name
git pull

if [ ! -z $release_name ]
then 
    git tag -a $release_name -m "OpenSpecimen release $release_name"
    git checkout $release_name
fi

cd $master_dir/www/
bower install
npm install
cd $master_dir
gradle clean
gradle build

if [ ! -z $release_name ]
then       	
  git push git@github.com:krishagni/openspecimen.git $release_name
fi

