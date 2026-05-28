#!/bin/bash
# =========================================================
# MN - Module accessors: reading declarative schemas
# =========================================================

# Module registry (each module adds itself via ALL_MODULES)
ALL_MODULES=""

# Read a module property
mod_prop() {
    local mod="$1" prop="$2"
    local varname="MOD_${mod}_${prop}"
    echo "${!varname}"
}

# Read a field property from a module
mod_field_prop() {
    local mod="$1" field="$2" prop="$3"
    local varname="MOD_${mod}_FIELD_${prop}_${field}"
    echo "${!varname}"
}

# Load field names into _MOD_FIELDS
mod_get_fields() {
    local mod="$1"
    local varname="MOD_${mod}_FIELDS"
    read -ra _MOD_FIELDS <<< "${!varname}"
}

# Get the title of a menu
get_menu_title() {
    local menu="$1"
    case "$menu" in
        main) echo "$T_MENU_TITLE" ;;
        config) echo "$T_MENU_TITLE_CONFIG" ;;
        docs) echo "$T_MENU_TITLE_DOCS" ;;
        *)
            local title
            title=$(mod_prop "$menu" "TITLE")
            [[ -n "$title" ]] && echo "$title" || echo "$menu"
            ;;
    esac
}

# Yes/No display helper
_display_yes_no() {
    [[ -n "$1" ]] && echo "$T_YES" || echo "$T_NO"
}
