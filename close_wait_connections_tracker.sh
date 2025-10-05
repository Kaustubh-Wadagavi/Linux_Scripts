#!/bin/bash
# close_wait_connections_tracker.sh

SNAPSHOT_DIR="./snapshots"
mkdir -p "$SNAPSHOT_DIR"

# Monitored ports
TOMCAT_PORT=8080
APACHE_PORT=443
DB_PORT=1521

DATE_TIME=$(date +"%Y-%m-%d_%H-%M-%S")
CURRENT_SNAPSHOT="$SNAPSHOT_DIR/close_wait_snapshot_$DATE_TIME.txt"

# Function to check if connection exists in snapshots
checkIfConnectionExists() {
    local conns="$1"
    local IFS=$'\n'  # split on newline
    local current_ts=$(date '+%Y-%m-%d %H:%M:%S')

    for connection in $conns; do
        local found_in_all=true
        local oldest_ts="$current_ts"

        for file in "$SNAPSHOT_DIR"/*; do
            [ -f "$file" ] || continue

            match=$(grep -F "$connection" "$file")
            if [ -z "$match" ]; then
                found_in_all=false
                break
            else
                ts=$(echo "$match" | sed -n 's/.*| CLOSE_WAIT since: \(.*\)/\1/p')
                if [[ "$ts" < "$oldest_ts" ]]; then
                    oldest_ts="$ts"
                fi
            fi
        done

        if $found_in_all; then
            echo "$connection | CLOSE_WAIT since: $oldest_ts" >> "$CURRENT_SNAPSHOT"
        else
            echo "$connection | CLOSE_WAIT since: $current_ts" >> "$CURRENT_SNAPSHOT"
        fi
    done
}

# Function to get current CLOSE_WAIT connections
get_current_connections() {
    netstat -antp 2>/dev/null | grep CLOSE_WAIT | grep -E ":$TOMCAT_PORT|:$APACHE_PORT|:$DB_PORT"
}

# Main function
main() {
    connections=$(get_current_connections)
    checkIfConnectionExists "$connections"
}

main
