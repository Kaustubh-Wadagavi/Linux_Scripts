#!/bin/bash
# close_wait_connections_tracker.sh
# Track CLOSE_WAIT connections and print conn, close_wait_since, elapsed time, <24h / >24h

SNAPSHOT_DIR="./snapshots"
mkdir -p "$SNAPSHOT_DIR"

# Monitored ports
TOMCAT_PORT=8080
APACHE_PORT=443
DB_PORT=1521

DATE_TIME_SUFFIX=$(date +"%Y-%m-%d_%H-%M-%S")
CURRENT_SNAPSHOT="$SNAPSHOT_DIR/close_wait_snapshot_$DATE_TIME_SUFFIX.txt"
REPORT_FILE="$SNAPSHOT_DIR/close_wait_report_$DATE_TIME_SUFFIX.txt"

##########################################
# Get current CLOSE_WAIT connections for monitored ports
##########################################
get_current_connections() {
    netstat -antp 2>/dev/null | grep CLOSE_WAIT | grep -E ":$TOMCAT_PORT|:$APACHE_PORT|:$DB_PORT"
}

##########################################
# Save snapshot with first_seen timestamp (epoch)
##########################################
save_snapshot() {
    local conns="$1"
    local first_seen_file="$2"

    : > "$CURRENT_SNAPSHOT"
    local now_epoch=$(date +%s)

    while read -r line; do
        # Use full line as key for uniqueness
        local conn_key="$line"
        local first_seen="$now_epoch"

        # Check if conn exists in first_seen_file
        if [[ -f "$first_seen_file" ]]; then
            stored=$(grep -F "$conn_key" "$first_seen_file" | awk '{print $NF}')
            [[ -n "$stored" ]] && first_seen="$stored"
        fi

        echo "$conn_key $first_seen" >> "$CURRENT_SNAPSHOT"
    done <<< "$conns"
}

##########################################
# Generate report with elapsed time and <24h / >24h
##########################################
generate_report() {
    : > "$REPORT_FILE"
    local now_epoch=$(date +%s)

    echo "Latest snapshot time: $DATE_TIME_SUFFIX" >> "$REPORT_FILE"
    echo "----------------------------------------------------" >> "$REPORT_FILE"

    while read -r line; do
        local conn_line=$(echo "$line" | awk '{$NF=""; print $0}')
        local first_seen_epoch=$(echo "$line" | awk '{print $NF}')

        local close_wait_since=$(date -d "@$first_seen_epoch" +"%Y-%m-%d_%H-%M-%S")

        local elapsed_sec=$(( now_epoch - first_seen_epoch ))
        local hours=$(( elapsed_sec / 3600 ))
        local minutes=$(( (elapsed_sec % 3600) / 60 ))
        local label="<24h"
        (( elapsed_sec >= 86400 )) && label=">24h"

        echo "$conn_line, close_wait_since: $close_wait_since, elapsed: ${hours}h ${minutes}m, $label" >> "$REPORT_FILE"
    done < "$CURRENT_SNAPSHOT"

    echo "Report saved to $REPORT_FILE"
}

##########################################
# Main function
##########################################
main() {
    local conns
    conns=$(get_current_connections)

    # Find oldest snapshot (first seen file)
    oldest_snapshot=$(ls -1tr "$SNAPSHOT_DIR"/close_wait_snapshot_*.txt 2>/dev/null | head -n 1)

    save_snapshot "$conns" "$oldest_snapshot"

    # If this is the first run, no report
    if [[ -z "$oldest_snapshot" ]]; then
        echo "First run: snapshot created at $CURRENT_SNAPSHOT"
        return
    fi

    generate_report "$oldest_snapshot"
}

main
