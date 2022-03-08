#!/bin/bash

filename=jenkins_backup_`date +%Y-%m-%d`

echo "Changing directory to Jenkins home"
cd /home/jenkins/jenkins_home

tar --exclude='./workspace' -zcvf $filename.tgz /home/jenkins/jenkins_home/

mv /home/jenkins/jenkins_home/jenkins_backup_`date +%Y-%m-%d`.tgz ~/jenkins_backup/

scp $filename.tgz demo@demo.openspecimen.org:/home/demo/jenkins_backup/
