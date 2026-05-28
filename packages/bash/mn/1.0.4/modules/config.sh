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
    show_cursor

    echo -e "${WHITE}$T_CONFIG_LANG_CURRENT:${NC} ${CYAN}$MN_LANG${NC}\n"

    local langs=() names=() f code name i=1
    for f in "$MN_DIR"/lang/*.sh; do
        [[ -f "$f" ]] || continue
        code=$(basename "$f" .sh)
        name=$(. "$f" 2>/dev/null; printf '%s' "${LANG_DISPLAY_NAME:-$code}")
        langs+=("$code")
        names+=("$name")
        echo -e "  ${WHITE}${i})${NC} $name"
        ((i++))
    done

    echo -ne "\n${CYAN}${T_CHOICE}:${NC} "
    read -r lang_input

    local new_lang="$MN_LANG" j
    if [[ "$lang_input" =~ ^[0-9]+$ ]] && (( lang_input >= 1 && lang_input < i )); then
        new_lang="${langs[lang_input-1]}"
    else
        for j in "${!langs[@]}"; do
            if [[ "${langs[j]}" == "$lang_input" ]]; then
                new_lang="${langs[j]}"
                break
            fi
        done
    fi

    if [[ "$new_lang" != "$MN_LANG" ]]; then
        echo "$new_lang" > "$MN_LANG_FILE"
        echo -e "\n${GREEN}✓ $T_CONFIG_LANG_CHANGED${NC}"
        sleep 2
        cleanup
    fi

    hide_cursor
    show_config_menu
}

config_change_editor() {
    clear_screen
    draw_header "$T_CONFIG_EDITOR_TITLE"
    show_cursor

    echo -e "${WHITE}$T_CONFIG_EDITOR_CURRENT:${NC} ${CYAN}$MN_EDITOR${NC}\n"
    echo -e "  ${WHITE}1)${NC} vi"
    echo -e "  ${WHITE}2)${NC} vim"
    echo -e "  ${WHITE}3)${NC} nano"
    echo -e "  ${WHITE}4)${NC} zed"
    echo -e "  ${WHITE}5)${NC} VS Code (code -n)"
    echo -e "  ${WHITE}6)${NC} $T_CONFIG_EDITOR_CUSTOM"
    echo -ne "\n${CYAN}${T_CHOICE}:${NC} "
    read -r editor_input

    local new_editor="$MN_EDITOR"
    case "$editor_input" in
        1) new_editor="vi" ;;
        2) new_editor="vim" ;;
        3) new_editor="nano" ;;
        4) new_editor="zed" ;;
        5) new_editor="code -n" ;;
        6)
            echo -ne "\n${CYAN}$T_CONFIG_EDITOR_CUSTOM:${NC} "
            read -r new_editor
            ;;
    esac

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

    hide_cursor
    show_config_menu
}

config_uninstall() {
    clear_screen
    draw_header "$T_CONFIG_UNINSTALL_TITLE"
    show_cursor

    echo -e "\n${RED}$T_CONFIG_UNINSTALL_CONFIRM${NC}\n"
    echo -e "  ${WHITE}1)${NC} $T_YES"
    echo -e "  ${WHITE}2)${NC} $T_NO"
    echo -ne "\n${CYAN}${T_CHOICE}:${NC} "
    read -r confirm_input

    case "$confirm_input" in
        1|y|Y|yes|oui)
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
            ;;
        *)
            hide_cursor
            show_config_menu
            ;;
    esac
}
