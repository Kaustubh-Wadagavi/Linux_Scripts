#/bin/bash

#This script removes the symbolic links created reccursively in the OpenSpecimen app UI component's directory.
if [ -L /home/jenkins/jenkins_home/workspace/os_source/openspecimen_core/www/bower_components/bower_components ]; then
  rm /home/jenkins/jenkins_home/workspace/os_source/openspecimen_core/www/bower_components/bower_components
fi

if [ -L /home/jenkins/jenkins_home/workspace/os_source/openspecimen_core/www/external_components/external_components ]; then
  rm /home/jenkins/jenkins_home/workspace/os_source/openspecimen_core/www/external_components/external_components
fi

if [ -L /home/jenkins/jenkins_home/workspace/os_source/openspecimen_core/www/node_modules/node_modules ]; then
  rm /home/jenkins/jenkins_home/workspace/os_source/openspecimen_core/www/node_modules/node_modules
fi

if [ -L /home/jenkins/jenkins_home/workspace/os_source/openspecimen/www/bower_components/bower_components ]; then
  rm /home/jenkins/jenkins_home/workspace/os_source/openspecimen/www/bower_components/bower_components
fi

if [ -L /home/jenkins/jenkins_home/workspace/os_source/openspecimen/www/external_components/external_components ]; then
  rm /home/jenkins/jenkins_home/workspace/os_source/openspecimen/www/external_components/external_components
fi

if [ -L /home/jenkins/jenkins_home/workspace/os_source/openspecimen/www/node_modules/node_modules ]; then
  rm /home/jenkins/jenkins_home/workspace/os_source/openspecimen/www/node_modules/node_modules
fi

