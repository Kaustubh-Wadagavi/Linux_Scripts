#!/bin/bash

appUrl=$1

opsmnMonitoring() {
  wget --no-check-certificate -o applog  $appUrl/rest/ng/config-settings/app-props
  rc=$?;
  if [ $rc -eq 0 ]
  then
    exit 0;
  else
    exit -1;
  fi
}

main() {
  opsmnMonitoring;
}
main; 
