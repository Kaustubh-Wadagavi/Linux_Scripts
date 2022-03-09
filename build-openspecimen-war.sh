#!/bin/bash

branch_name=$1
release_name=$2
master_dir="/mnt/volume_nyc1_01/new_workspace/os_source/openspecimen"
os_core="/mnt/volume_nyc1_01/new_workspace/os_source/openspecimen_core"

npm cache clean --force
/home/jenkins/jenkins_home/workspace/os_source/jenkins_script/remove-links.sh

if [ "$branch_name" = "$release_name" ]
then
   cd $master_dir
   git checkout $brach_name
   git pull
   cd $master_dir/www/
   bower install
   npm install
   cd $master_dir
   gradle clean
   gradle build
elif [ "$branch_name" != "$release_name" ]
then
  cd $os_core
  git checkout master
  git pull
  exists=`git ls-remote --heads origin $branch_Name`
  if [ -n "$exists" ]; then
   echo "Branch Name Exists"
   git checkout $branch_Name
   git pull
   git tag -a $release_name -m "OpenSpecimen release $release_name"
   git checkout $release_name
   cd $os_core/www/
   bower install
   npm install
   cd $os_core
   gradle clean
   gradle build
   git push git@github.com:krishagni/openspecimen.git $release_name
   cd
   else
      echo "Branch Name Does Not Exist"
      git checkout master
      git pull
      git tag -a $release_name -m "OpenSpecimen release $release_name"
      git checkout $release_name
      cd $os_core/www/
      bower install
      npm install
      cd $os_core
      gradle clean
      gradle build
      git push git@github.com:krishagni/openspecimen.git $release_name
    fi
fi
