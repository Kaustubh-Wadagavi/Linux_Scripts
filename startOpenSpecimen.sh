#!/bin/bash

URL=http://localhost:8080/os/
TOMCAT_HOME=/usr/local/openspecimen/tomcat-as/
EMAIL_ID="do-not-reply@krishagni.com"
EMAIL_PASS="fmhrtiydtzqnfyke"
RCPT_EMAIL_ID="kaustubh@krishagni.com"
CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT=587
CLIENT_NAME_AND_ENVIRONMENT="OpenSpecimen/Kaustubh: Test Server"

ALL_ERRORS=""

sendEmail() {
    local SUBJECT=$1
    local BODY=$2
    curl -s --url "smtp://$SMTP_SERVER:$SMTP_PORT" --ssl-reqd \
        --mail-from "$EMAIL_ID" --mail-rcpt "$RCPT_EMAIL_ID" \
        --upload-file <(echo -e "From: $EMAIL_ID\nTo: $RCPT_EMAIL_ID\nSubject: $SUBJECT\n\n$BODY") \
        --user "$EMAIL_ID:$EMAIL_PASS"
}

genericErrorNotification() {
    local ERROR_DETAILS=$1
    ALL_ERRORS="$ALL_ERRORS\n$ERROR_DETAILS"
}

# Set trap to catch errors
trap 'genericErrorNotification "An unexpected error occurred in the script: $(cat /tmp/script_error.log)"; exit 1' ERR

restartServer() {
    if [[ ! -f "$TOMCAT_HOME/bin/pid.txt" ]]; then
        genericErrorNotification "pid.txt not found!"
        exit 1
    fi
    
    if (( $(ps -ef | grep -v grep | grep tomcat | wc -l) > 0 )); then
        $TOMCAT_HOME/bin/shutdown.sh -force 2>/tmp/script_error.log
        local SHUTDOWN_STATUS=$?
        if [[ $SHUTDOWN_STATUS -ne 0 ]]; then
            genericErrorNotification "Tomcat shutdown failed: $(cat /tmp/script_error.log)"
            exit 1
        fi

        $TOMCAT_HOME/bin/startup.sh 2>/tmp/script_error.log
        local STARTUP_STATUS=$?
        if [[ $STARTUP_STATUS -ne 0 ]]; then
            genericErrorNotification "Tomcat startup failed: $(cat /tmp/script_error.log)"
            exit 1
        fi

        sendEmail "$CLIENT_NAME_AND_ENVIRONMENT Restarted Successfully" "Hello,\n\nThe OpenSpecimen server restarted successfully at $CURRENT_TIME. Please check why it was restarted.\n\nThanks."
        return 0
    else
        genericErrorNotification "Tomcat process not running!"
        exit 1
    fi
}

checkPid() {
    if [ -f "$TOMCAT_HOME/bin/pid.txt" ]; then
      return 0;
    else 
      return 1;
    fi
}

invokeApi() {
    wget --no-check-certificate -O applog $URL/rest/ng/config-settings/app-props 2>/tmp/script_error.log
    local WGET_STATUS=$?
    if [[ $WGET_STATUS -ne 0 ]]; then
        echo "Warning: API invocation failed, but ignoring wget error."
        genericErrorNotification "API invocation failed: $(cat /tmp/script_error.log)"
        return 1
    fi
    return 0
}

main() {
    for ((COUNT=0; COUNT <= 1; COUNT++)); do
        invokeApi
        if [[ $? -eq 0 ]]; then
            echo "App is running..."
            trap - ERR
            exit 0
        fi
        sleep 10
    done

    checkPid
    PID_EXISTS=$?
    if [ $PID_EXISTS -eq 0 ]; then
      restartServer
      exit 0
    fi

    # Send accumulated errors if any
    if [[ -n "$ALL_ERRORS" ]]; then
        sendEmail "$CLIENT_NAME_AND_ENVIRONMENT Error Notifications" "Hello,\n\nThe following errors occurred during script execution at $CURRENT_TIME:\n$ALL_ERRORS\n\nPlease investigate the issues.\n\nThanks."
    fi

    exit 0 
}

main;
