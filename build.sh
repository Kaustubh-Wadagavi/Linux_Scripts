#!/bin/bash

repo_dir=$1
branch_name=$2
release_name=$3

if [ ! -d $repo_dir ] || [ -z $branch_name ] || [ -z $release_name ]
then
   echo "Usage: ./build.sh <repository_directory_path> <repository_branch_name> <release_name>"
   echo "Please specify absolute respository directory path, branch name and tag name."
   exit 0;
fi

npm cache clean --force

cd "$repo_dir"

repository_url=$(git config --get remote.origin.url)
echo "$repository_url"
git pull

exists=`git ls-remote --heads origin $branch_name`
if [ ! -n "$exists" ]
then
   echo "branch doesn't exist"
   exit 0;
fi

git checkout $branch_name

if [ ! -z $release_name ] && [ $release_name != "master" ]
then
    git tag -a $release_name -m "OpenSpecimen release $release_name"
    git checkout $release_name
fi

if [ -d "$repo_dir/WEB-INF" ]
then	
   cd "$repo_dir/www/"
   bower install
   npm install
   cd "$repo_dir"
else
   core_app=$(cd ../openspecimen; pwd)
   component="./src/main/"	
   ln -sf "$core_app/www/bower_components" "$component/webapp/bower_components"
   ln -sf "$core_app/www/node_modules" "$component/webapp/node_modules"
   if [ -d "./src/main/ui" ]
   then
     ln -sf "$core_app/ui/node_modules" "$component/ui/node_modules"
   fi
fi

gradle clean
gradle build

if [ ! -z $release_name ] && [ $release_name != "master" ]
then
  git push $repository_url $release_name
fi
