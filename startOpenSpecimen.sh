#!/bin/bash

URL=https://host/
TOMCAT_HOME=/usr/local/openspecimen/tomcat-as/bin/
EMAIL_ID="do-not-reply@krishagni.com"
EMAIL_PASS=""
RCPT_EMAIL_ID=""
CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT=587
CLIENT_NAME_AND_ENVIRONMENT="OpenSpecimen/CUMC: Test Server"

ALL_ERRORS=""
RESTART_SUCCESS=false

LOG_FILE="/tmp/auto_restart.log"

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

        exit 0
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
    curl -i $URL/rest/ng/config-settings/app-props >/dev/null 2>/tmp/script_error.log
    return $?
}

main() {
    echo "[$CURRENT_TIME] Starting script execution" >> $LOG_FILE
    for ((COUNT=1; COUNT <=10; COUNT++)); do
        invokeApi
        STATUS=$?
        if [[ $STATUS -eq 0 ]]; then
            echo "[$CURRENT_TIME] App is running..." >> $LOG_FILE
            trap - ERR
            exit 0
        fi
        sleep 10
    done

    checkPid
    PID_EXISTS=$?
    if [ $PID_EXISTS -eq 0 ]; then
        echo "[$CURRENT_TIME] Server restart triggered." >> $LOG_FILE
        restartServer
    fi

    if [[ -n "$ALL_ERRORS" ]]; then
        # If there were errors and the server wasn't successfully restarted
        if [[ "$RESTART_SUCCESS" == false ]]; then
            sendEmail "$CLIENT_NAME_AND_ENVIRONMENT Auto Restart Script Error Notifications" "Hello,\n\nThe following errors occurred during auto restart script execution at $CURRENT_TIME:\n$ALL_ERRORS\n\nPlease investigate the issues.\n\nThanks."
        fi
    fi

    echo "[$CURRENT_TIME] Script execution completed." >> $LOG_FILE
    exit 0
}

main;
