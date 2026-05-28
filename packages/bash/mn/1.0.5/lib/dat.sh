#!/bin/bash
# =========================================================
# MN - DAT helpers: manipulation of .dat files
# =========================================================

# Parse a ::: line into the _DAT_FIELDS array
dat_parse() {
    local line="$1"
    _DAT_FIELDS=()
    while [[ "$line" == *":::"* ]]; do
        _DAT_FIELDS+=("${line%%:::*}")
        line="${line#*:::}"
    done
    _DAT_FIELDS+=("$line")
}

# Read an entry by its key (field 0)
dat_read() {
    local file="$1"
    local key="$2"
    local line
    line=$(grep "^${key}:::" "$file" | head -1)
    if [[ -z "$line" ]]; then
        _DAT_FIELDS=()
        return 1
    fi
    dat_parse "$line"
    return 0
}

# Rebuild a ::: line from arguments
dat_join() {
    local result=""
    local first=true
    for field in "$@"; do
        if $first; then
            result="$field"
            first=false
        else
            result="$result:::$field"
        fi
    done
    echo "$result"
}

# Delete an entry by key
dat_delete_entry() {
    local file="$1"
    local key="$2"
    local tmp
    tmp=$(mktemp)
    awk -v k="$key" 'BEGIN{FS=":::"} $1!=k' "$file" > "$tmp"
    mv "$tmp" "$file"
}
