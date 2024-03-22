#!/bin/bash

authenticate_session() {
    local LOGIN_NAME="$1"
    local PASSWORD="$2"
    local OTP="$3" 
    local REQUEST_DATA=$(cat <<EOF
    {
       "domainName": "openspecimen",
       "loginName": "$LOGIN_NAME",
       "password": "$PASSWORD",
       "props": {
         "otp": "$OTP"
       }
    }
EOF
    )
    
    SESSION_INFO=$(curl -s -X POST -H "Content-Type: application/json" -d "$REQUEST_DATA" "$API_URL/rest/ng/sessions")
    echo $SESSION_INFO 
    if [ -z "$SESSION_INFO" ]; then
        echo "Authentication failed. Unable to obtain session information."
        exit 1
    fi
    
    SESSION_TOKEN=$(echo "$SESSION_INFO" | jq -r '.token')
    
}

main() {
    API_URL="https://darpan.openspecimen.org/"
    echo "OpenSpecimen API Authentication"
    echo "--------------------------------"
    
    read -p "Enter login name: " LOGIN_NAME
    read -p "Enter password: " PASSWORD
    echo ""
    read -p "Enter OTP: " OTP
    
    echo "Authenticating session..."
    authenticate_session "$LOGIN_NAME" "$PASSWORD" "$OTP"
    
    echo "Session authenticated successfully."
    echo "" 
    echo "Auth Token: $SESSION_TOKEN"

}

main

