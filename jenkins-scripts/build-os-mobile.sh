#!/bin/bash

#Input to this script are mobile app version and directory where application APK will be stored.
osMobileAppsDir=$1
appVersion=$2
osMobileWorkspace="/home/jenkins/jenkins_home/workspace/os_source/os-mobile"
certKeyPath="/home/jenkins/jenkins_home/workspace/os_source/keystore"
keyAlias="openspecimen-release"

if [ -z "$osMobileAppsDir" ]; then
  echo "Please specify the absolute path of directory where application APK will be kept."
fi

if [ -z "$appVersion" ]; then
  appVersion=$(date '+%Y-%m-%d')
fi

cd $osMobileWorkspace
git checkout master
git pull
echo "Creating a debug APK..."
$osMobileWorkspace/./gradlew clean
$osMobileWorkspace/./gradlew assembleDebug
cp $osMobileWorkspace/app/build/outputs/apk/debug/app-debug.apk "/home/jenkins/jenkins_home/workspace/os_source/Mobile App/debug/os-mobile-debug-$appVersion.apk"

echo "Creating a released APK..."
$osMobileWorkspace/./gradlew clean
$osMobileWorkspace/./gradlew assembleRelease

echo "Signing the release APK..."
apksigner sign --ks $certKeyPath/openspecimen-release.keystore --ks-pass pass:testingpurpose $osMobileWorkspace/app/build/outputs/apk/release/app-release-unsigned.apk

echo "Verifying sign using apksigner verify..."
apksigner verify $osMobileWorkspace/app/build/outputs/apk/release/app-release-unsigned.apk

echo "Moving signed APK to Mobile App directory."
cp $osMobileWorkspace/app/build/outputs/apk/release/app-release-unsigned.apk "/home/jenkins/jenkins_home/workspace/os_source/Mobile App/release/os-mobile-release-$appVersion.apk"

