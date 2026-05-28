#!/bin/bash
# =========================================================
# MN - Module: Configuration
# =========================================================

show_config_menu() {
    CURRENT_MENU="config"
    SELECTED_INDEX=0
    USE_PAGINATION=false

    MENU_ITEMS=(
        "${MAGENTA}[M]${NC} $T_CONFIG_EDIT_MN"
        "${BLUE}[B]${NC} $T_CONFIG_EDIT_ALIASES"
        "${BLUE}[F]${NC} $T_CONFIG_EDIT_FUNCS"
        "${BLUE}[R]${NC} $T_CONFIG_EDIT_BASHRC"
        "${GREEN}[S]${NC} $T_CONFIG_SOURCE"
        "${CYAN}[L]${NC} $T_CONFIG_LANG"
        "${CYAN}[E]${NC} $T_CONFIG_EDITOR"
        "${RED}[X]${NC} $T_CONFIG_UNINSTALL"
    )
    MENU_ACTIONS=(
        "config_edit_mn"
        "config_edit_aliases"
        "config_edit_functions"
        "config_edit_bashrc"
        "config_source_all"
        "config_change_lang"
        "config_change_editor"
        "config_uninstall"
    )
}

config_edit_mn() {
    show_cursor
    $MN_EDITOR "$MN_DIR"
    hide_cursor
    show_config_menu
}

config_edit_aliases() {
    show_cursor
    $MN_EDITOR "$BASH_ALIASES"
    hide_cursor
    show_config_menu
}

config_edit_functions() {
    show_cursor
    $MN_EDITOR "$BASH_FUNCTIONS"
    hide_cursor
    show_config_menu
}

config_edit_bashrc() {
    show_cursor
    $MN_EDITOR "$HOME/.bashrc"
    hide_cursor
    show_config_menu
}

config_source_all() {
    clear_screen
    draw_header "$T_CONFIG_REGEN_TITLE"

    echo -e "${CYAN}$T_CONFIG_REGEN_MSG${NC}\n"

    regenerate_bash_files

    echo -e "  ${GREEN}✓${NC} ~/.bash_aliases"
    echo -e "  ${GREEN}✓${NC} ~/.bash_functions"
    echo -e "\n${GREEN}$T_CONFIG_REGEN_DONE${NC}"

    sleep 1
    hide_cursor
    show_config_menu
}

config_change_lang() {
    clear_screen
    draw_header "$T_CONFIG_LANG_TITLE"

    echo -e "${WHITE}$T_CONFIG_LANG_CURRENT:${NC} ${CYAN}$MN_LANG${NC}\n"

    local -a sel_opts=()
    local f code name init_idx=0 idx=0
    for f in "$MN_DIR"/lang/*.sh; do
        [[ -f "$f" ]] || continue
        code=$(basename "$f" .sh)
        name=$(. "$f" 2>/dev/null; printf '%s' "${LANG_DISPLAY_NAME:-$code}")
        sel_opts+=("${code}:::${name}")
        [[ "$code" == "$MN_LANG" ]] && init_idx=$idx
        (( idx++ ))
    done

    _SELECT_INDEX=$init_idx
    if select_option "" "${sel_opts[@]}"; then
        local new_lang="$_SELECT_VALUE"
        if [[ "$new_lang" != "$MN_LANG" ]]; then
            echo "$new_lang" > "$MN_LANG_FILE"
            echo -e "\n${GREEN}✓ $T_CONFIG_LANG_CHANGED${NC}"
            sleep 2
            cleanup
        fi
    fi

    hide_cursor
    show_config_menu
}

config_change_editor() {
    clear_screen
    draw_header "$T_CONFIG_EDITOR_TITLE"

    echo -e "${WHITE}$T_CONFIG_EDITOR_CURRENT:${NC} ${CYAN}$MN_EDITOR${NC}\n"

    local preset_vals=("vi" "vim" "nano" "zed" "code -n")
    local preset_labels=("vi" "vim" "nano" "zed" "VS Code (code -n)")
    local -a sel_opts=()
    local init_idx=5 i
    for (( i=0; i<${#preset_vals[@]}; i++ )); do
        sel_opts+=("${preset_vals[$i]}:::${preset_labels[$i]}")
        [[ "${preset_vals[$i]}" == "$MN_EDITOR" ]] && init_idx=$i
    done
    sel_opts+=("__custom__:::$T_CONFIG_EDITOR_CUSTOM")

    _SELECT_INDEX=$init_idx
    if select_option "" "${sel_opts[@]}"; then
        local new_editor="$_SELECT_VALUE"
        if [[ "$new_editor" == "__custom__" ]]; then
            show_cursor
            echo -ne "\n${CYAN}$T_CONFIG_EDITOR_CUSTOM:${NC} "
            read -r new_editor
        fi

        if [[ -z "${new_editor// }" || "$new_editor" == *"'"* ]]; then
            new_editor="$MN_EDITOR"
        fi

        if [[ "$new_editor" != "$MN_EDITOR" ]]; then
            echo "$new_editor" > "$MN_EDITOR_FILE"
            MN_EDITOR="$new_editor"
            regenerate_bash_files
            echo -e "\n${GREEN}✓ $T_CONFIG_EDITOR_CHANGED${NC}"
            sleep 2
        fi
    fi

    hide_cursor
    show_config_menu
}

config_uninstall() {
    clear_screen
    draw_header "$T_CONFIG_UNINSTALL_TITLE"

    echo -e "\n${RED}$T_CONFIG_UNINSTALL_CONFIRM${NC}\n"

    if confirm_dialog; then
        # Remove symlink
        for bin_dir in /usr/local/bin "$HOME/.local/bin" "$HOME/bin"; do
            [ -L "$bin_dir/mn" ] && rm -f "$bin_dir/mn"
        done

        # Clean shell config
        for rc in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile" "$HOME/.zshrc"; do
            if [ -f "$rc" ] && grep -q "# Added by mn installer" "$rc"; then
                sed -i '/# Added by mn installer/d;/export PATH=.*mn/d' "$rc"
            fi
        done

        # Remove mn function from bash_functions
        [ -f "$HOME/.bash_functions" ] && sed -i '/^mn()/d' "$HOME/.bash_functions"

        # Remove config directory
        rm -rf "$MN_DIR"

        show_cursor
        echo -e "\n${GREEN}$T_CONFIG_UNINSTALL_DONE${NC}\n"
        exit 0
    fi

    hide_cursor
    show_config_menu
}
