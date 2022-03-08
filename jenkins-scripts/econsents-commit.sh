#!/bin/bash

unix_time=`date -d "$date -1 days" +"%Y-%m-%d"`

cd /home/jenkins/jenkins_home/workspace/os_source/openspecimen
git log --after="$unix_time 00:00" >> commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/dashboard
git log --after="$unix_time 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/distribution-invoicing
git log --after="$unix_time 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/os-extras
git log --after="$unix_time 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/rde
git log --after="$unix_time 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/sde
git log --after="$unix_time 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/specimen-array
git log --after="$unix_time 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/specimen-catalog
git log --after="$unix_time 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/specimen-gel
git log --after="$unix_time 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

cd /home/jenkins/jenkins_home/workspace/os_source/econsents
git log --after="$unix_time 00:00" >> /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt

mv /home/jenkins/jenkins_home/workspace/os_source/openspecimen/commit.txt /home/jenkins/jenkins_home/workspace/os_source/Check\ Econsents\ App\ Status/
