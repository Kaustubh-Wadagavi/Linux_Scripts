#!/bin/bash
# close_wait_tracer.sh
# Track CLOSE_WAIT connections for Tomcat, Apache, and Database ports only
# Logs all connections with waiting time, >24h/<24h, thread details, and snapshot
# Files are timestamped with date and time

# ------------------- CONFIG -------------------
DATE_TIME_SUFFIX=$(date +"%Y-%m-%d_%H-%M-%S")
STATE_FILE="close_wait_tracker.db"
SNAPSHOT_FILE="close_wait_snapshot_$DATE_TIME_SUFFIX.txt"
LOG_FILE="close_wait_tracker_$DATE_TIME_SUFFIX.log"

TOMCAT_PORT=8080
APACHE_PORT=443
DATABASE_PORT=1521

NOW=$(date +"%s")
CUTOFF=$((NOW - 86400))  # 24 hours
# ---------------------------------------------

#####################################
# Save snapshot file with service category and duration
#####################################
save_snapshot() {
    declare -n st=$1
    log "Saving snapshot with thread details and exact timing..."
    : > "$SNAPSHOT_FILE"
    for conn in "${!st[@]}"; do
        first_seen=${st[$conn]}
        elapsed=$((NOW - first_seen))
        hours=$(( elapsed / 3600 ))
        minutes=$(( (elapsed % 3600) / 60 ))
        label="[<24h]"
        (( elapsed >= 86400 )) && label="[>24h]"
        service=$(get_service_category "$conn")
        first_seen_ts=$(date -d "@$first_seen" +"%Y-%m-%d %H:%M:%S")
        echo "$conn [$service] (first seen: $first_seen_ts, elapsed: ${hours}h ${minutes}m $label)" >> "$SNAPSHOT_FILE"
        log "$conn [$service] (first seen: $first_seen_ts, elapsed: ${hours}h ${minutes}m $label)"
    done
    log "Snapshot saved to $SNAPSHOT_FILE"
}

#####################################
# Save updated state back to file
#####################################
save_state() {
    declare -n st=$1
    log "Saving updated state..."
    : > "$STATE_FILE"
    for conn in "${!st[@]}"; do
        echo "$conn|${st[$conn]}" >> "$STATE_FILE"
    done
    log "State saved with ${#st[@]} connections."
}

#####################################
# Load previous state from file
#####################################
load_state() {
    log "Loading previous state..."
    declare -A state
    if [[ -f "$STATE_FILE" ]]; then
        while IFS="|" read -r conn first_seen; do
            [[ -n "$conn" ]] && state["$conn"]=$first_seen
        done < "$STATE_FILE"
        log "Loaded ${#state[@]} previous connections."
    else
        log "No previous state found, starting fresh."
    fi
    echo "$(declare -p state)"
}

#####################################
# Get all CLOSE_WAIT connections for monitored ports
#####################################
get_close_wait_connections() {
    log "Fetching current CLOSE_WAIT connections with thread info..."
    # Filter CLOSE_WAIT connections for monitored ports, include PID/Program
    netstat -antp 2>/dev/null | grep CLOSE_WAIT | grep -E ":$TOMCAT_PORT|:$APACHE_PORT|:$DATABASE_PORT"
}


#####################################
# Get Service By port
#####################################
get_service_category() {
    local line="$1"
    if [[ "$line" == *":$TOMCAT_PORT "* ]] || [[ "$line" == *":$TOMCAT_PORT->"* ]]; then
        echo "TOMCAT"
    elif [[ "$line" == *":$APACHE_PORT "* ]] || [[ "$line" == *":$APACHE_PORT->"* ]]; then
        echo "APACHE"
    elif [[ "$line" == *":$DATABASE_PORT "* ]] || [[ "$line" == *":$DATABASE_PORT->"* ]]; then
        echo "DATABASE"
    else
        echo "UNKNOWN"
    fi
}

#####################################
# Logging function
#####################################
log() {
    local msg="$1"
    local ts
    ts=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$ts] $msg" | tee -a "$LOG_FILE"
}

#####################################
# Main logic
#####################################
main() {
    log "--------------------------------------------"
    log "Starting CLOSE_WAIT tracker run..."

    conns=$(get_close_wait_connections)
    count=$(echo "$conns" | wc -l)
    log "Found $count CLOSE_WAIT connections in current snapshot."

    eval "$(load_state)"
    declare -A newstate

    log "Updating state with current snapshot..."
    while IFS= read -r conn; do
        # Use the entire netstat line as key to preserve thread info
        if [[ -n "${state[$conn]}" ]]; then
            newstate["$conn"]=${state[$conn]}
        else
            newstate["$conn"]=$NOW
            log "New CLOSE_WAIT detected: $conn"
        fi
    done <<< "$conns"

    save_state newstate
    save_snapshot newstate

    log "CLOSE_WAIT tracker run completed."
    log "--------------------------------------------"
}

main
