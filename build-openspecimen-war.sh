#!/bin/bash

repo_dir=$1
branch_name=$2
release_name=$3
core_app="/mnt/volume_nyc1_01/new_workspace/os_source/openspecimen"
component="./src/main/"

if [ -z $branch_name ] || [ ! -d $repo_dir ]
then
   echo "1. If you releasing only master build the please provide repo_dir path and branch name. "
   echo "2. If you releasing the version the please provide a. repo_dir b. branch name and c. release name with command line"
   exit 0;
fi

npm cache clean --force

cd $repo_dir

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

cd "$repo_dir"

if [ -d "$repo_dir/WEB-INF" ]
then	
   cd "$repo_dir/www/"
   bower install
   npm install
else 
   ln -sf "$core_app/www/bower_components" "$component/webapp/bower_components"
   ln -sf "$core_app/www/node_modules" "$component/webapp/node_modules"
   ln -sf "$core_app/www/external_components" "$component/webapp/external_components"
   if [ -d "./src/main/ui" ]
   then
     ln -sf "$core_app/ui/node_modules" "$componentui/ui/node_modules"
   fi
fi

gradle clean
gradle build

if [ ! -z $release_name ]
then
  git push git@github.com:krishagni/openspecimen.git $release_name
fi
