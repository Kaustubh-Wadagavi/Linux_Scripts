#!/bin/bash
# close_wait_connections_tracker.sh

SNAPSHOT_DIR="./snapshots"
mkdir -p "$SNAPSHOT_DIR"

TOMCAT_PORT=8080
APACHE_PORT=443
DB_PORT=1521

DATE_TIME=$(date +"%Y-%m-%d_%H-%M-%S")
CURRENT_SNAPSHOT="$SNAPSHOT_DIR/close_wait_snapshot_$DATE_TIME.txt"

checkIfConnectionExists() {
    local conns="$1"
    local IFS=$'\n'
    local current_ts
    current_ts=$(date '+%Y-%m-%d %H:%M:%S')

    shopt -s nullglob
    local files=( "$SNAPSHOT_DIR"/close_wait_snapshot_*.txt )
    shopt -u nullglob

    if [ ${#files[@]} -eq 0 ]; then
        for connection in $conns; do
            echo "$connection | CLOSE_WAIT since: $current_ts" >> "$CURRENT_SNAPSHOT"
        done
        return
    fi

    IFS=$'\n' sorted_files=($(printf "%s\n" "${files[@]}" | sort))
    IFS=$'\n'

    for connection in $conns; do
        local run_start_ts=""
        local in_run=false

        for file in "${sorted_files[@]}"; do
            [ -f "$file" ] || continue

            if grep -Fq -- "$connection" "$file"; then
                if [ "$in_run" = false ]; then
                    if ts=$(date -r "$file" '+%Y-%m-%d %H:%M:%S' 2>/dev/null); then
                        run_start_ts="$ts"
                    else
                        if ts=$(stat -c %y "$file" 2>/dev/null | cut -d'.' -f1); then
                            run_start_ts="$ts"
                        else
                            run_start_ts="$current_ts"
                        fi
                    fi
                    in_run=true
                fi
            else
                in_run=false
                run_start_ts=""
            fi
        done

        if [ "$in_run" = true ] && [ -n "$run_start_ts" ]; then
            echo "$connection | CLOSE_WAIT since: $run_start_ts" >> "$CURRENT_SNAPSHOT"
        else
            echo "$connection | CLOSE_WAIT since: $current_ts" >> "$CURRENT_SNAPSHOT"
        fi
    done

}

get_current_connections() {
    netstat -antp 2>/dev/null | grep CLOSE_WAIT | grep -E ":$TOMCAT_PORT|:$APACHE_PORT|:$DB_PORT"

}

main() {
    connections=$(get_current_connections)
    checkIfConnectionExists "$connections"

}

main
