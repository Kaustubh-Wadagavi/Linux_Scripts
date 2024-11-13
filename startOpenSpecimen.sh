#!/bin/bash

URL=http://localhost:8080/openspecimen/
TOMCAT_HOME=/usr/local/openspecimen/tomcat-as/bin/
EMAIL_ID=
EMAIL_PASS=
RCPT_EMAIL_ID=
CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT=587
CLIENT_NAME_AND_ENVIRONMENT="OpenSpecimen/Kaustubh: Test Server"

ALL_ERRORS=""
RESTART_SUCCESS=false

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
    if (( $(ps -ef | grep -v grep | grep tomcat | wc -l) > 0 )); then
        $TOMCAT_HOME/shutdown.sh -force 2>/tmp/script_error.log
        local SHUTDOWN_STATUS=$?
        if [[ $SHUTDOWN_STATUS -ne 0 ]]; then
            genericErrorNotification "Tomcat shutdown failed: $(cat /tmp/script_error.log)"
            return 1
        fi

        $TOMCAT_HOME/startup.sh 2>/tmp/script_error.log
        local STARTUP_STATUS=$?
        if [[ $STARTUP_STATUS -ne 0 ]]; then
            genericErrorNotification "Tomcat startup failed: $(cat /tmp/script_error.log)"
            return 1
        fi

        RESTART_SUCCESS=true  # Mark restart as successful
        if [[ "$RESTART_SUCCESS" == true ]]; then
           sendEmail "$CLIENT_NAME_AND_ENVIRONMENT Restarted Successfully" "Hello,\n\nThe OpenSpecimen server restarted successfully at $CURRENT_TIME. Please check why it was restarted.\n\nThanks."
        fi

	return 0
    fi
}

checkPid() {
    if [ -f "$TOMCAT_HOME/pid.txt" ]; then
      return 0
    else
      exit 0
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
    # Retry API invocation up to 10 times
    for ((COUNT=0; COUNT <= 10; COUNT++)); do
        invokeApi
        if [[ $? -eq 0 ]]; then
            echo "App is running..."
            trap - ERR
            exit 0
        fi
        sleep 10
    done

    # Check if PID file exists, then attempt to restart the server
    checkPid
    PID_EXISTS=$?
    if [ $PID_EXISTS -eq 0 ]; then
        restartServer
    fi

    # Send the appropriate email based on the outcome
    if [[ -n "$ALL_ERRORS" ]]; then
        # If there were errors and the server wasn't successfully restarted
        if [[ "$RESTART_SUCCESS" == false ]]; then
            sendEmail "$CLIENT_NAME_AND_ENVIRONMENT Auto Restart Script Error Notifications" "Hello,\n\nThe following errors occurred during auto restart script execution at $CURRENT_TIME:\n$ALL_ERRORS\n\nPlease investigate the issues.\n\nThanks."
        fi
    fi

    exit 0;
}

main;
