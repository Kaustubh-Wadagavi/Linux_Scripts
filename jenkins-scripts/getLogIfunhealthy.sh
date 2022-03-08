#!/bin/bash

retry_count=1;
max_retry_count=10;
url=$1
app_name=$2

invoke_server_api() {
  wget -t 10 -T 60 --no-check-certificate -o applog  $url/rest/ng/config-settings/app-props
  rc=$?;
  if [ $rc -eq 0 ]
  then
    echo "App is running";
    exit 0;
  fi
}

load_config_props() {
  if [ $retry_count -gt $max_retry_count ]
  then
    if [ "$app_name" == "os-econsents" ]
    then
      scp openspecimen@test.openspecimen.org:/home/openspecimen/openspecimen/app/tomcat-as/logs/catalina.out .
      scp openspecimen@test.openspecimen.org:/home/openspecimen/openspecimen/app/econsent/data/logs/os.log .
      tail -200 os.log > econ_error.txt
      tail -100 catalina.out > econ_catalina.txt
      exit -1;
    else
      scp openspecimen@test.openspecimen.org:/home/openspecimen/openspecimen/app/tomcat-as/logs/catalina.out .
      scp openspecimen@test.openspecimen.org:/home/openspecimen/openspecimen/app/openspecimen/data/logs/os.log .
      tail -200 os.log > error.txt
      tail -100 catalina.out > catalina.txt
      exit -1;
    fi
  fi
  invoke_server_api;
  sleep 10
  ((++retry_count));
  load_config_props;
}

main() {
  load_config_props;
}
main;
