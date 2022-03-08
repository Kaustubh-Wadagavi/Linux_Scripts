#!/bin/bash

echo "Stopping Jenkins..."
systemctl stop jenkins.service
sleep 5

echo "Removing log files"
rm /usr/local/jenkins/tomcat/logs/*
sleep 5

echo "Starting Jenkins..."
systemctl start jenkins.service
