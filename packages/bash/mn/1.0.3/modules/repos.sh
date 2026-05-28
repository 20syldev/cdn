#!/bin/bash
# =========================================================
# MN - Module: GitHub Repositories
# =========================================================

# -------------------- CONFIG -------------------- #

REPOS_DEFAULT_PATH="~/Documents/GitHub/Repositories"

# -------------------- SCHEMA -------------------- #

MOD_repos_FILE="$REPOS_FILE"
MOD_repos_TITLE="$T_REPOS_TITLE"
MOD_repos_TITLE_ADD="$T_REPOS_TITLE_ADD"
MOD_repos_NOUN="$T_REPOS_NOUN"
MOD_repos_ADD_LABEL="$T_REPOS_ADD_LABEL"
MOD_repos_FIELDS="name path desc"
MOD_repos_PAGINATION="true"
MOD_repos_REGEN="true"
MOD_repos_CLI_ARGS="repos|repo|r"
MOD_repos_MENU_FORMAT_FN="_repos_menu_format"
MOD_repos_ENTRY_ACTION="repos_manage"

MOD_repos_FIELD_LABEL_name="$T_REPOS_F_NAME"
MOD_repos_FIELD_REQUIRED_name="yes"
MOD_repos_FIELD_TYPE_name="text"

MOD_repos_FIELD_LABEL_path="$T_REPOS_F_PATH"
MOD_repos_FIELD_REQUIRED_path="no"
MOD_repos_FIELD_TYPE_path="text"
MOD_repos_FIELD_DEFAULT_FN_path="_repos_default_path_fn"
MOD_repos_FIELD_TRANSFORM_FN_path="_repos_path_transform"

MOD_repos_FIELD_LABEL_desc="$T_REPOS_F_DESC"
MOD_repos_FIELD_REQUIRED_desc="no"
MOD_repos_FIELD_TYPE_desc="text"

# -------------------- FORMAT -------------------- #

_repos_menu_format() {
    dat_parse "$1"
    local name="${_DAT_FIELDS[0]}" path="${_DAT_FIELDS[1]}"
    echo -e "${CYAN}$name${NC} ${WHITE}-${NC} ${GRAY}$path${NC}"
}

# -------------------- HELPERS -------------------- #

_repos_default_path_fn() {
    echo "${REPOS_DEFAULT_PATH}/$1"
}

_repos_path_transform() {
    local input="$1"
    local name="$2"
    if [[ -z "$input" ]]; then
        echo "${REPOS_DEFAULT_PATH}/${name}"
    elif [[ "$input" != /* && "$input" != ~* ]]; then
        echo "${REPOS_DEFAULT_PATH}/${input}"
    else
        echo "$input"
    fi
}

# -------------------- HOOKS -------------------- #

repos_manage() {
    local name="$1"
    dat_read "$REPOS_FILE" "$name"
    local path="${_DAT_FIELDS[1]}"
    repos_open "$name" "$path"
}

repos_open() {
    local name="$1"
    local path="$2"
    show_cursor
    clear_screen
    eval path="$path"

    spinner_start "$T_REPOS_OPENING ${WHITE}$name${NC}..."
    $MN_EDITOR "$path"
    spinner_stop

    kill -HUP $PPID 2>/dev/null
    exit 0
}

# -------------------- WRAPPER -------------------- #

show_repos_menu() { generic_show_menu "repos"; }

# Register the module
ALL_MODULES="${ALL_MODULES:+$ALL_MODULES }repos"
