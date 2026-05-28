#!/bin/bash
# =========================================================
# MN - UI: header, footer, menu engine, input
# =========================================================

draw_header() {
    local title="$1"
    get_terminal_size

    echo -e "${CYAN}${BOLD}"
    echo -e "  $title"
    echo -e "${RESET}"
}

confirm_dialog() {
    local selected=1
    hide_cursor

    while true; do
        tput el
        if [[ $selected -eq 0 ]]; then
            echo -e "  ${WHITE}[${GREEN}✓${WHITE} $T_CONFIRM]${NC}   ${RED}✗${NC} $T_CANCEL"
        else
            echo -e "   ${GREEN}✓${NC} $T_CONFIRM   ${WHITE}[${RED}✗${WHITE} $T_CANCEL]${NC}"
        fi

        read -rsn1 key
        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key
            case "$key" in
                '[C'|'[D') selected=$(( 1 - selected )) ;;
            esac
        else
            case "$key" in
                h|l) selected=$(( 1 - selected )) ;;
                ''|$'\n')
                    show_cursor
                    return $selected
                    ;;
            esac
        fi
        tput cuu1
    done
}

draw_footer() {
    local is_crud_menu=false
    for mod in $ALL_MODULES; do
        [[ "$CURRENT_MENU" == "$mod" ]] && is_crud_menu=true && break
    done

    local base
    [[ "$CURRENT_MENU" == "main" ]] && base="$T_FOOTER_QUIT" || base="$T_FOOTER_BASE"

    if $is_crud_menu; then
        if [[ $SELECTED_INDEX -gt 0 ]]; then
            echo -e "\n${DIM}  $base  $T_FOOTER_CRUD${NC}"
        else
            echo -e "\n${DIM}  $base  $T_FOOTER_ADD${NC}"
        fi
    else
        echo -e "\n${DIM}  $base  $T_FOOTER_SELECT${NC}"
    fi
}

draw_menu() {
    local title="$1"
    local total_items=${#MENU_ITEMS[@]}
    local start_idx=0
    local end_idx=$total_items
    local total_pages=1

    if [[ "$USE_PAGINATION" == "true" && $total_items -gt $ITEMS_PER_PAGE ]]; then
        total_pages=$(( (total_items + ITEMS_PER_PAGE - 1) / ITEMS_PER_PAGE ))
        start_idx=$(( CURRENT_PAGE * ITEMS_PER_PAGE ))
        end_idx=$(( start_idx + ITEMS_PER_PAGE ))
        [[ $end_idx -gt $total_items ]] && end_idx=$total_items
    fi

    tput cup 0 0

    echo -e "${CYAN}${BOLD}"
    tput el
    echo -e "  $title"
    tput el
    echo -e "${RESET}"

    if [[ "$USE_PAGINATION" == "true" && $total_pages -gt 1 ]]; then
        tput el
        echo -e "${DIM}  $T_PAGE_INFO $((CURRENT_PAGE + 1))/$total_pages  $T_PAGE_CHANGE${NC}"
        tput el
        echo ""
    fi

    local idx=0
    for item in "${MENU_ITEMS[@]}"; do
        if [[ $idx -ge $start_idx && $idx -lt $end_idx ]]; then
            tput el
            if [[ $idx -eq $SELECTED_INDEX ]]; then
                echo -e "  ${REVERSE} ${item} ${RESET}"
            else
                echo -e "  ${item}"
            fi
        fi
        ((idx++))
    done

    tput ed
    draw_footer
}

handle_input() {
    local key

    read -rsn1 key

    if [[ "$key" == $'\x1b' ]]; then
        read -rsn2 -t 0.1 key
        case "$key" in
            '[A') key="UP" ;;
            '[B') key="DOWN" ;;
            '[C') key="RIGHT" ;;
            '[D') key="LEFT" ;;
            *) return ;;
        esac
    fi

    local total_items=${#MENU_ITEMS[@]}
    local total_pages=1
    if [[ "$USE_PAGINATION" == "true" && $total_items -gt $ITEMS_PER_PAGE ]]; then
        total_pages=$(( (total_items + ITEMS_PER_PAGE - 1) / ITEMS_PER_PAGE ))
    fi

    case "$key" in
        UP|k)
            ((SELECTED_INDEX--))
            if [[ $SELECTED_INDEX -lt 0 ]]; then
                SELECTED_INDEX=$((total_items - 1))
                if [[ "$USE_PAGINATION" == "true" && $total_pages -gt 1 ]]; then
                    CURRENT_PAGE=$((total_pages - 1))
                    LAST_MENU=""
                fi
            elif [[ "$USE_PAGINATION" == "true" && $total_pages -gt 1 ]]; then
                local page_start=$(( CURRENT_PAGE * ITEMS_PER_PAGE ))
                if [[ $SELECTED_INDEX -lt $page_start ]]; then
                    ((CURRENT_PAGE--))
                    LAST_MENU=""
                fi
            fi
            ;;
        DOWN|j)
            ((SELECTED_INDEX++))
            if [[ $SELECTED_INDEX -ge $total_items ]]; then
                SELECTED_INDEX=0
                CURRENT_PAGE=0
                if [[ "$USE_PAGINATION" == "true" && $total_pages -gt 1 ]]; then
                    LAST_MENU=""
                fi
            elif [[ "$USE_PAGINATION" == "true" && $total_pages -gt 1 ]]; then
                local page_end=$(( (CURRENT_PAGE + 1) * ITEMS_PER_PAGE ))
                if [[ $SELECTED_INDEX -ge $page_end ]]; then
                    ((CURRENT_PAGE++))
                    LAST_MENU=""
                fi
            fi
            ;;
        LEFT|'<'|',')
            if [[ "$USE_PAGINATION" == "true" && $CURRENT_PAGE -gt 0 ]]; then
                ((CURRENT_PAGE--))
                SELECTED_INDEX=$(( CURRENT_PAGE * ITEMS_PER_PAGE ))
                LAST_MENU=""
            fi
            ;;
        RIGHT|'>'|'.')
            if [[ "$USE_PAGINATION" == "true" && $CURRENT_PAGE -lt $((total_pages - 1)) ]]; then
                ((CURRENT_PAGE++))
                SELECTED_INDEX=$(( CURRENT_PAGE * ITEMS_PER_PAGE ))
                LAST_MENU=""
            fi
            ;;
        ''|$'\n')
            execute_action
            ;;
        e|E)
            execute_quick_action "edit"
            ;;
        d|D)
            execute_quick_action "delete"
            ;;
        v|V)
            execute_quick_action "view"
            ;;
        q|Q)
            quit_menu
            ;;
        r|R)
            if [[ "$CURRENT_MENU" != "main" ]]; then
                SELECTED_INDEX=0; CURRENT_PAGE=0; show_main_menu
            fi
            ;;
    esac
}

execute_action() {
    local action="${MENU_ACTIONS[$SELECTED_INDEX]}"

    if [[ "$action" == *":::"* ]]; then
        local cmd="${action%%:::*}"
        local params="${action#*:::}"

        local -a PARAMS=()
        while [[ "$params" == *":::"* ]]; do
            PARAMS+=("${params%%:::*}")
            params="${params#*:::}"
        done
        PARAMS+=("$params")

        $cmd "${PARAMS[@]}"
    else
        $action
    fi
}

execute_quick_action() {
    local quick_action="$1"
    local action="${MENU_ACTIONS[$SELECTED_INDEX]}"

    [[ "$action" == generic_add* ]] && return

    if [[ "$action" == *":::"* ]]; then
        local params="${action#*:::}"
        local name
        while [[ "$params" == *":::"* ]]; do
            params="${params#*:::}"
        done
        name="$params"

        case "$quick_action" in
            edit)
                local edit_fn
                edit_fn=$(mod_prop "$CURRENT_MENU" "EDIT_FN")
                if [[ -n "$edit_fn" ]]; then
                    $edit_fn "$name"
                else
                    generic_edit "$CURRENT_MENU" "$name"
                fi
                ;;
            delete)
                generic_delete "$CURRENT_MENU" "$name"
                ;;
            view)
                local view_fn
                view_fn=$(mod_prop "$CURRENT_MENU" "VIEW_FN")
                if [[ -n "$view_fn" ]]; then
                    $view_fn "$name"
                else
                    generic_view "$CURRENT_MENU" "$name"
                fi
                ;;
        esac
    fi

    LAST_MENU=""
}

cleanup() {
    show_cursor
    tput cnorm
    clear_screen
    exit 0
}

quit_menu() {
    cleanup
}

# Main loop
main_loop() {
    hide_cursor
    trap 'cleanup' INT TERM EXIT

    show_main_menu
    draw_menu "$T_MENU_TITLE" "true"
    LAST_MENU="main"

    while true; do
        handle_input

        local redraw_mode="false"
        if [[ "$CURRENT_MENU" != "$LAST_MENU" ]]; then
            redraw_mode="true"
            LAST_MENU="$CURRENT_MENU"
        fi

        local title
        title=$(get_menu_title "$CURRENT_MENU")
        draw_menu "$title" "$redraw_mode"
    done
}

# Launch a submenu directly
_run_submenu() {
    local mod="$1"
    local title
    title=$(mod_prop "$mod" "TITLE")
    hide_cursor
    trap 'cleanup' INT TERM EXIT
    generic_show_menu "$mod"
    LAST_MENU="$mod"
    draw_menu "$title" "true"
    while true; do
        handle_input
        local redraw="false"
        [[ -z "$LAST_MENU" ]] && redraw="true" && LAST_MENU="$mod"
        title=$(get_menu_title "$CURRENT_MENU")
        draw_menu "$title" "$redraw"
    done
}
