#!/bin/bash

# Logs the data to the Google Drive worklog directory

# Usage
# w "Created README"

# Note: a tilde inside quotes is NOT expanded by the shell, so use $HOME.
# Resolved per call (never cached in a shell variable) so that re-sourcing this
# file always picks up a changed default. Export WORKLOG_DIR to override.
_worklog_dir() {
    echo "${WORKLOG_DIR:-$HOME/Library/CloudStorage/GoogleDrive-albin.george@booking.com/My Drive/worklog}"
}

# Add an entry
ww() {
    local dir="$(_worklog_dir)"
    local filename="$dir/$(date +%Y_%m_%d.log)"
    if [[ $# -eq 0 ]] ; then
        tail -n 20 "$filename"
    else
        local content="$(date +%H:%M:%S) - $*"
        mkdir -p "$dir"
        echo "$content"
        echo "$content" >> "$filename"
    fi
}

# accept a parameter which can either be an integer, say n(represents no of days) or a string of YYYY-MM-DD format.

# If the parameter is number of days, cat the file n days before. Example, if it's 1, look at the file yesterday.

# If the parameter is date, cat the file pointing to that specific date.
ww_() {
    if [[ $# -eq 0 ]] ; then
        echo "Usage: ww_ <days_ago|YYYY-MM-DD>"
        return 1
    fi

    local param="$1"
    local target_date

    # Check if parameter is a number (days ago)
    if [[ "$param" =~ ^[0-9]+$ ]] ; then
        # Calculate date n days ago
        if [[ "$OSTYPE" == "darwin"* ]] ; then
            # macOS date command
            target_date=$(date -v-${param}d +%Y_%m_%d)
        else
            # Linux date command
            target_date=$(date -d "$param days ago" +%Y_%m_%d)
        fi
    # Check if parameter is in YYYY-MM-DD format
    elif [[ "$param" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] ; then
        # Convert YYYY-MM-DD to YYYY_MM_DD
        target_date=$(echo "$param" | sed 's/-/_/g')
    else
        echo "Invalid parameter. Use either a number (days ago) or YYYY-MM-DD format."
        return 1
    fi

    local filename="$(_worklog_dir)/${target_date}.log"

    if [[ -f "$filename" ]] ; then
        cat "$filename"
    else
        echo "File not found: $filename"
        return 1
    fi
}

ww_edit() {
    local dir="$(_worklog_dir)"
    mkdir -p "$dir"
    subl "$dir/$(date +%Y_%m_%d.log)"
}

w() {
    local dir="$(_worklog_dir)"
    local filename="$dir/list.log"
    if [[ $# -eq 0 ]] ; then
        tail -n 20 "$filename"
    else
        local content="$(date '+%Y-%m-%d %H:%M:%S') - $*"
        mkdir -p "$dir"
        echo "$content"
        echo "$content" >> "$filename"
    fi
}

w_edit() {
    local dir="$(_worklog_dir)"
    mkdir -p "$dir"
    subl "$dir/list.log"
}
