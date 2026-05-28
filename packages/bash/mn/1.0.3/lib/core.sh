#!/bin/bash
# =========================================================
# MN - Core: configuration, colors, variables, utilities
# =========================================================

# -------------------- CONFIGURATION -------------------- #

MN_DIR="$HOME/.config/mn"
DATA_DIR="$MN_DIR/data"

# Data files
CONNEXIONS_FILE="$DATA_DIR/connexions.dat"
REPOS_FILE="$DATA_DIR/repos.dat"
ALIAS_FILE="$DATA_DIR/aliases.dat"
FUNCS_FILE="$DATA_DIR/functions.dat"

# Bash files
BASH_ALIASES="$HOME/.bash_aliases"
BASH_FUNCTIONS="$HOME/.bash_functions"

# -------------------- LANGUAGE -------------------- #

MN_LANG_FILE="$MN_DIR/.lang"
MN_LANG="fr"
[[ -f "$MN_LANG_FILE" ]] && MN_LANG=$(cat "$MN_LANG_FILE")
[[ "$MN_LANG" != "fr" && "$MN_LANG" != "en" ]] && MN_LANG="fr"
source "$MN_DIR/lang/${MN_LANG}.sh"

# -------------------- EDITOR -------------------- #

MN_EDITOR_FILE="$MN_DIR/.editor"
MN_EDITOR="vi"
[[ -f "$MN_EDITOR_FILE" ]] && MN_EDITOR=$(cat "$MN_EDITOR_FILE")
[[ -z "${MN_EDITOR// }" ]] && MN_EDITOR="vi"

# -------------------- COLORS AND STYLES -------------------- #

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'
RESET='\033[0m'
FG_RESET='\033[39m'

BG_BLUE='\033[44m'
BG_CYAN='\033[46m'
BG_BLACK='\033[40m'

# -------------------- GLOBAL VARIABLES -------------------- #

CURRENT_MENU="main"
LAST_MENU=""
SELECTED_INDEX=0
MENU_ITEMS=()
MENU_ACTIONS=()
SCREEN_ROWS=0
SCREEN_COLS=0

CURRENT_PAGE=0
ITEMS_PER_PAGE=15
USE_PAGINATION=false

MN_RUN_FILE="/tmp/mn_run_cmd"

# -------------------- UTILITY FUNCTIONS -------------------- #

init_data_files() {
    mkdir -p "$DATA_DIR"
    [[ ! -f "$CONNEXIONS_FILE" ]] && touch "$CONNEXIONS_FILE"
    [[ ! -f "$REPOS_FILE" ]] && touch "$REPOS_FILE"
    [[ ! -f "$ALIAS_FILE" ]] && touch "$ALIAS_FILE"
    [[ ! -f "$FUNCS_FILE" ]] && touch "$FUNCS_FILE"
    [[ ! -f "$BASH_FUNCTIONS" ]] && touch "$BASH_FUNCTIONS"
}

sort_dat_file() {
    local file="$1"
    local tmp_header tmp_body
    tmp_header=$(mktemp)
    tmp_body=$(mktemp)

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^# ]]; then
            echo "$line" >> "$tmp_header"
        elif [[ -n "$line" ]]; then
            echo "$line" >> "$tmp_body"
        fi
    done < "$file"

    if [[ -s "$tmp_header" ]]; then
        cat "$tmp_header" > "$file"
    else
        : > "$file"
    fi
    [[ -s "$tmp_body" ]] && sort -f -t':' -k1,1 "$tmp_body" >> "$file"

    rm -f "$tmp_header" "$tmp_body"
}

regenerate_bash_files() {
    local tmp_aliases tmp_functions
    tmp_aliases=$(mktemp)
    tmp_functions=$(mktemp)

    if [[ -f "$ALIAS_FILE" && -s "$ALIAS_FILE" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            local name="${line%%:::*}"
            local rest="${line#*:::}"
            local cmd="${rest%%:::*}"
            echo "alias $name='$cmd'" >> "$tmp_aliases"
        done < "$ALIAS_FILE"
    fi

    if [[ -f "$REPOS_FILE" && -s "$REPOS_FILE" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            local name="${line%%:::*}"
            local rest="${line#*:::}"
            local path="${rest%%:::*}"
            echo "alias $name='$MN_EDITOR $path && exit;'" >> "$tmp_aliases"
        done < "$REPOS_FILE"
    fi

    sort -f -t'=' -k1,1 "$tmp_aliases" > "$BASH_ALIASES"
    echo "" >> "$BASH_ALIASES"
    echo '[[ -f ~/.bash_functions ]] && source ~/.bash_functions' >> "$BASH_ALIASES"

    echo 'mn() { ~/.config/mn/mn "$@" && source ~/.bash_aliases; if [[ -f /tmp/mn_run_cmd ]]; then local _mn_cmd; _mn_cmd=$(cat /tmp/mn_run_cmd); rm -f /tmp/mn_run_cmd; read -e -i "$_mn_cmd" _mn_cmd && history -s "$_mn_cmd" && eval "$_mn_cmd"; fi; }' >> "$tmp_functions"

    if [[ -f "$FUNCS_FILE" && -s "$FUNCS_FILE" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            local name="${line%%:::*}"
            local rest="${line#*:::}"
            local desc="${rest%%:::*}"
            local type="${rest#*:::}"
            if [[ "$type" == "shell" ]]; then
                echo "$name() { source /usr/local/bin/$name \"\$@\"; }" >> "$tmp_functions"
            fi
        done < "$FUNCS_FILE"
    fi

    sort -f -t'(' -k1,1 "$tmp_functions" > "$BASH_FUNCTIONS"
    rm -f "$tmp_aliases" "$tmp_functions"
}

get_terminal_size() {
    SCREEN_ROWS=$(tput lines)
    SCREEN_COLS=$(tput cols)
}

clear_screen() {
    tput clear
    tput cup 0 0
}

hide_cursor() { tput civis; }
show_cursor() { tput cnorm; }

center_text() {
    local text="$1"
    local width="${2:-$SCREEN_COLS}"
    local text_len=${#text}
    local padding=$(( (width - text_len) / 2 ))
    printf "%*s%s%*s" $padding "" "$text" $padding ""
}

spinner_start() {
    local msg="$1"
    local frames="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    _SPINNER_PID=""
    (
        local i=0
        while true; do
            echo -ne "\r${CYAN}${frames:i%${#frames}:1}${NC} $msg"
            ((i++))
            sleep 0.08
        done
    ) &
    _SPINNER_PID=$!
}

spinner_stop() {
    [[ -n "$_SPINNER_PID" ]] && kill "$_SPINNER_PID" 2>/dev/null && wait "$_SPINNER_PID" 2>/dev/null
    _SPINNER_PID=""
    printf "\r\033[K"
}
