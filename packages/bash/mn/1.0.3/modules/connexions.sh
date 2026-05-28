#!/bin/bash
# =========================================================
# MN - Module: SSH / Custom connections
# =========================================================

# -------------------- SCHEMA -------------------- #

MOD_connexions_FILE="$CONNEXIONS_FILE"
MOD_connexions_TITLE="$T_CONN_TITLE"
MOD_connexions_TITLE_ADD="$T_CONN_TITLE_ADD"
MOD_connexions_NOUN="$T_CONN_NOUN"
MOD_connexions_ADD_LABEL="$T_CONN_ADD_LABEL"
MOD_connexions_FIELDS="label ip desc conn_type password cmd"
MOD_connexions_PAGINATION="false"
MOD_connexions_REGEN="false"
MOD_connexions_CLI_ARGS="connexions|conn"
MOD_connexions_MENU_FORMAT_FN="_connexions_menu_format"
MOD_connexions_ENTRY_ACTION="connexions_connect"

MOD_connexions_FIELD_LABEL_label="$T_CONN_F_LABEL"
MOD_connexions_FIELD_REQUIRED_label="yes"
MOD_connexions_FIELD_TYPE_label="text"

MOD_connexions_FIELD_LABEL_ip="$T_CONN_F_IP"
MOD_connexions_FIELD_REQUIRED_ip="yes"
MOD_connexions_FIELD_TYPE_ip="text"

MOD_connexions_FIELD_LABEL_desc="$T_CONN_F_DESC"
MOD_connexions_FIELD_REQUIRED_desc="no"
MOD_connexions_FIELD_TYPE_desc="text"

MOD_connexions_FIELD_LABEL_conn_type="$T_CONN_F_TYPE"
MOD_connexions_FIELD_REQUIRED_conn_type="no"
MOD_connexions_FIELD_TYPE_conn_type="choice"
MOD_connexions_FIELD_CHOICES_conn_type="1:ssh:$T_CONN_TYPE_SSH|2:custom:$T_CONN_TYPE_CUSTOM"
MOD_connexions_FIELD_DEFAULT_conn_type="ssh"

MOD_connexions_FIELD_LABEL_password="$T_CONN_F_PASS"
MOD_connexions_FIELD_REQUIRED_password="no"
MOD_connexions_FIELD_TYPE_password="password"
MOD_connexions_FIELD_DISPLAY_FN_password="_display_yes_no"

MOD_connexions_FIELD_LABEL_cmd="$T_CONN_F_CMD"
MOD_connexions_FIELD_REQUIRED_cmd="no"
MOD_connexions_FIELD_TYPE_cmd="text"

# -------------------- FORMAT -------------------- #

_connexions_menu_format() {
    dat_parse "$1"
    local label="${_DAT_FIELDS[0]}" ip="${_DAT_FIELDS[1]}" desc="${_DAT_FIELDS[2]}"
    local conn_type="${_DAT_FIELDS[3]}"
    local type_icon="ssh"
    [[ "$conn_type" == "custom" ]] && type_icon="~"
    echo -e "${CYAN}$label${NC} ${GRAY}[$type_icon]${NC} ${GRAY}($ip)${NC} ${WHITE}-${NC} ${GRAY}$desc${NC}"
}

# -------------------- HOOKS -------------------- #

connexions_connect() {
    local label="$1"
    dat_read "$CONNEXIONS_FILE" "$label"
    local ip="${_DAT_FIELDS[1]}"
    local conn_type="${_DAT_FIELDS[3]:-ssh}"
    local cmd="${_DAT_FIELDS[5]}"

    show_cursor
    clear

    trap 'spinner_stop; exit 1' INT
    spinner_start "$T_CONN_CONNECTING ${WHITE}$label${NC} ($ip)..."
    sleep 1
    spinner_stop
    trap - INT TERM EXIT

    if [[ "$conn_type" == "custom" ]]; then
        exec bash -ic "$cmd && sleep 1 && clear"
    else
        exec bash -ic "ssh $ip && sleep 1 && clear"
    fi
}

# -------------------- WRAPPER -------------------- #

show_connexions_menu() { generic_show_menu "connexions"; }

# Register the module
ALL_MODULES="${ALL_MODULES:+$ALL_MODULES }connexions"
