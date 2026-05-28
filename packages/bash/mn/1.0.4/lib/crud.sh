#!/bin/bash
# =========================================================
# MN - Generic CRUD engine
# =========================================================

# Build the menu of a module from its .dat file
generic_show_menu() {
    local mod="$1"
    CURRENT_MENU="$mod"
    SELECTED_INDEX=0
    CURRENT_PAGE=0

    local pagination
    pagination=$(mod_prop "$mod" "PAGINATION")
    USE_PAGINATION="$pagination"

    MENU_ITEMS=()
    MENU_ACTIONS=()

    local add_label
    add_label=$(mod_prop "$mod" "ADD_LABEL")
    MENU_ITEMS+=("${GREEN}[+]${NC} $add_label")
    MENU_ACTIONS+=("generic_add:::$mod")

    local dat_file format_fn entry_action
    dat_file=$(mod_prop "$mod" "FILE")
    format_fn=$(mod_prop "$mod" "MENU_FORMAT_FN")
    entry_action=$(mod_prop "$mod" "ENTRY_ACTION")

    if [[ -f "$dat_file" && -s "$dat_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            local key="${line%%:::*}"
            local display
            display=$($format_fn "$line")
            MENU_ITEMS+=("$display")
            MENU_ACTIONS+=("${entry_action}:::${key}")
        done < "$dat_file"
    fi
}

# Step-by-step add wizard
generic_add() {
    local mod="$1"
    local title dat_file noun regen
    title=$(mod_prop "$mod" "TITLE_ADD")
    dat_file=$(mod_prop "$mod" "FILE")
    noun=$(mod_prop "$mod" "NOUN")
    regen=$(mod_prop "$mod" "REGEN")

    show_cursor
    mod_get_fields "$mod"
    local fields=("${_MOD_FIELDS[@]}")
    local -a wiz_values=()
    local step=0

    for field in "${fields[@]}"; do
        clear_screen
        draw_header "$title"

        # Display previously filled fields with ✓
        local prev=0
        for prev_field in "${fields[@]}"; do
            [[ $prev -ge $step ]] && break
            local display_val="${wiz_values[$prev]}"
            local display_fn
            display_fn=$(mod_field_prop "$mod" "$prev_field" "DISPLAY_FN")
            [[ -n "$display_fn" ]] && display_val=$($display_fn "$display_val")
            local prev_label
            prev_label=$(mod_field_prop "$mod" "$prev_field" "LABEL")
            echo -e "  ${GREEN}✓${NC} $prev_label: ${WHITE}$display_val${NC}"
            ((prev++))
        done
        [[ $step -gt 0 ]] && echo ""

        # Field properties
        local label hint required field_type choices default_val default_fn
        label=$(mod_field_prop "$mod" "$field" "LABEL")
        hint=$(mod_field_prop "$mod" "$field" "HINT")
        required=$(mod_field_prop "$mod" "$field" "REQUIRED")
        field_type=$(mod_field_prop "$mod" "$field" "TYPE")
        choices=$(mod_field_prop "$mod" "$field" "CHOICES")
        default_val=$(mod_field_prop "$mod" "$field" "DEFAULT")
        default_fn=$(mod_field_prop "$mod" "$field" "DEFAULT_FN")

        # Compute dynamic default value
        if [[ -n "$default_fn" ]]; then
            default_val=$($default_fn "${wiz_values[@]}")
        fi

        local value=""
        case "$field_type" in
            text)
                local hint_display=""
                [[ -n "$hint" ]] && hint_display=" ${GRAY}$hint${NC}"
                echo -ne "${CYAN}${label}${hint_display}${CYAN}:${NC} "
                [[ -n "$default_val" ]] && echo -ne "${GRAY}[$default_val]${NC} "
                read -r value

                local transform_fn
                transform_fn=$(mod_field_prop "$mod" "$field" "TRANSFORM_FN")
                if [[ -n "$transform_fn" ]]; then
                    value=$($transform_fn "$value" "${wiz_values[@]}")
                elif [[ -z "$value" && -n "$default_val" ]]; then
                    value="$default_val"
                fi
                ;;
            password)
                local hint_display=""
                [[ -n "$hint" ]] && hint_display=" ${GRAY}$hint${NC}"
                echo -ne "${CYAN}${label}${hint_display}${CYAN}:${NC} "
                read -rs value
                echo ""
                ;;
            choice)
                echo -e "${CYAN}${label}:${NC}"
                local IFS_BAK="$IFS"
                IFS='|'
                local -a choice_items=($choices)
                IFS="$IFS_BAK"
                for c in "${choice_items[@]}"; do
                    local ckey="${c%%:*}"
                    local crest="${c#*:}"
                    local cdisplay="${crest#*:}"
                    echo -e "  ${WHITE}${ckey})${NC} $cdisplay"
                done
                echo -ne "${CYAN}${T_CHOICE}:${NC} "
                read -r choice_input
                for c in "${choice_items[@]}"; do
                    local ckey="${c%%:*}"
                    local crest="${c#*:}"
                    local cvalue="${crest%%:*}"
                    if [[ "$choice_input" == "$ckey" ]]; then
                        value="$cvalue"
                        break
                    fi
                done
                [[ -z "$value" && -z "$choice_input" ]] && value="$default_val"
                ;;
        esac

        wiz_values+=("$value")

        if [[ "$required" == "yes" && -z "$value" ]]; then
            echo -e "\n${RED}✗ $label $T_REQUIRED${NC}"
            sleep 1
            hide_cursor
            generic_show_menu "$mod"
            return
        fi

        ((step++))
    done

    # Write the line
    local dat_line
    dat_line=$(dat_join "${wiz_values[@]}")
    echo "$dat_line" >> "$dat_file"
    sort_dat_file "$dat_file"
    [[ "$regen" == "true" ]] && regenerate_bash_files

    # Post-add hook
    local post_add_fn
    post_add_fn=$(mod_prop "$mod" "POST_ADD_FN")
    if [[ -n "$post_add_fn" ]]; then
        $post_add_fn "${wiz_values[@]}"
    fi

    # Final summary
    clear_screen
    draw_header "$title"
    local idx=0
    for field in "${fields[@]}"; do
        local display_val="${wiz_values[$idx]}"
        local display_fn
        display_fn=$(mod_field_prop "$mod" "$field" "DISPLAY_FN")
        [[ -n "$display_fn" ]] && display_val=$($display_fn "$display_val")
        local flabel
        flabel=$(mod_field_prop "$mod" "$field" "LABEL")
        echo -e "  ${GREEN}✓${NC} $flabel: ${WHITE}$display_val${NC}"
        ((idx++))
    done
    local key_val="${wiz_values[0]}"
    echo -e "\n  ${GREEN}✓ ${noun^} '$key_val' $T_ADDED !${NC}"
    sleep 1
    hide_cursor
    generic_show_menu "$mod"
}

# Step-by-step edit wizard
generic_edit() {
    local mod="$1"
    local key="$2"
    local dat_file regen noun
    dat_file=$(mod_prop "$mod" "FILE")
    regen=$(mod_prop "$mod" "REGEN")
    noun=$(mod_prop "$mod" "NOUN")

    show_cursor
    dat_read "$dat_file" "$key"
    local -a old_values=("${_DAT_FIELDS[@]}")

    mod_get_fields "$mod"
    local fields=("${_MOD_FIELDS[@]}")

    local -a new_values=()
    new_values+=("$key")

    local edit_step=0

    for field in "${fields[@]:1}"; do
        local field_idx=$(( edit_step + 1 ))
        local old_val="${old_values[$field_idx]}"
        local label field_type choices
        label=$(mod_field_prop "$mod" "$field" "LABEL")
        field_type=$(mod_field_prop "$mod" "$field" "TYPE")
        choices=$(mod_field_prop "$mod" "$field" "CHOICES")

        clear_screen
        draw_header "${T_EDIT_PREFIX}: $key"

        # Display already edited fields with ✓
        local prev=0
        for prev_field in "${fields[@]:1}"; do
            [[ $prev -ge $edit_step ]] && break
            local prev_label
            prev_label=$(mod_field_prop "$mod" "$prev_field" "LABEL")
            local prev_idx=$(( prev + 1 ))
            local dv="${new_values[$prev_idx]}"
            local display_fn
            display_fn=$(mod_field_prop "$mod" "$prev_field" "DISPLAY_FN")
            [[ -n "$display_fn" ]] && dv=$($display_fn "$dv")
            echo -e "  ${GREEN}✓${NC} $prev_label: ${WHITE}$dv${NC}"
            ((prev++))
        done
        [[ $edit_step -gt 0 ]] && echo ""

        local value=""
        case "$field_type" in
            text)
                echo -ne "${CYAN}$label ${GRAY}(${T_KEEP_HINT} '${old_val}')${CYAN}:${NC} "
                read -r value
                [[ -z "$value" ]] && value="$old_val"
                ;;
            password)
                local has_pass="$T_NO"
                [[ -n "$old_val" ]] && has_pass="$T_YES"
                echo -e "${GRAY}$T_PASS_CURRENT: $has_pass${NC}"
                echo -ne "${CYAN}$label ${GRAY}(${T_PASS_KEEP_DEL})${CYAN}:${NC} "
                read -rs value
                echo ""
                [[ -z "$value" ]] && value="$old_val"
                [[ "$value" == "-" ]] && value=""
                ;;
            choice)
                echo -e "${CYAN}$label ${GRAY}($T_CURRENT: $old_val)${CYAN}:${NC}"
                local IFS_BAK="$IFS"
                IFS='|'
                local -a choice_items=($choices)
                IFS="$IFS_BAK"
                for c in "${choice_items[@]}"; do
                    local ckey="${c%%:*}"
                    local crest="${c#*:}"
                    local cdisplay="${crest#*:}"
                    echo -e "  ${WHITE}${ckey})${NC} $cdisplay"
                done
                echo -ne "${CYAN}${T_CHOICE}:${NC} "
                read -r choice_input
                value="$old_val"
                if [[ -n "$choice_input" ]]; then
                    for c in "${choice_items[@]}"; do
                        local ckey="${c%%:*}"
                        local crest="${c#*:}"
                        local cvalue="${crest%%:*}"
                        if [[ "$choice_input" == "$ckey" ]]; then
                            value="$cvalue"
                            break
                        fi
                    done
                fi
                ;;
        esac

        new_values+=("$value")
        ((edit_step++))
    done

    # Update the file
    dat_delete_entry "$dat_file" "$key"
    dat_join "${new_values[@]}" >> "$dat_file"
    sort_dat_file "$dat_file"
    [[ "$regen" == "true" ]] && regenerate_bash_files

    # Final summary
    clear_screen
    draw_header "${T_EDIT_PREFIX}: $key"
    local idx=0
    for field in "${fields[@]:1}"; do
        local fval="${new_values[$(( idx + 1 ))]}"
        local display_fn
        display_fn=$(mod_field_prop "$mod" "$field" "DISPLAY_FN")
        [[ -n "$display_fn" ]] && fval=$($display_fn "$fval")
        local flabel
        flabel=$(mod_field_prop "$mod" "$field" "LABEL")
        echo -e "  ${GREEN}✓${NC} $flabel: ${WHITE}$fval${NC}"
        ((idx++))
    done
    echo -e "\n  ${GREEN}✓ ${noun^} $T_UPDATED !${NC}"
    sleep 1
    hide_cursor
    generic_show_menu "$mod"
}

# Deletion with confirmation
generic_delete() {
    local mod="$1"
    local key="$2"

    local custom_fn
    custom_fn=$(mod_prop "$mod" "DELETE_FN")
    if [[ -n "$custom_fn" ]]; then
        $custom_fn "$key"
        return
    fi

    local dat_file regen noun
    dat_file=$(mod_prop "$mod" "FILE")
    regen=$(mod_prop "$mod" "REGEN")
    noun=$(mod_prop "$mod" "NOUN")

    clear_screen
    draw_header "${T_DEL_PREFIX}: $key"
    show_cursor

    if dat_read "$dat_file" "$key"; then
        mod_get_fields "$mod"
        local idx=0
        for field in "${_MOD_FIELDS[@]}"; do
            local val="${_DAT_FIELDS[$idx]}"
            [[ -z "$val" ]] && { ((idx++)); continue; }
            local flabel
            flabel=$(mod_field_prop "$mod" "$field" "LABEL")
            local display_fn
            display_fn=$(mod_field_prop "$mod" "$field" "DISPLAY_FN")
            [[ -n "$display_fn" ]] && val=$($display_fn "$val")
            echo -e "${WHITE}$flabel:${NC} $val"
            ((idx++))
        done
    fi
    echo ""

    if confirm_dialog; then
        dat_delete_entry "$dat_file" "$key"
        [[ "$regen" == "true" ]] && regenerate_bash_files
        echo -e "\n${GREEN}✓ ${noun^} $T_DELETED !${NC}"
        sleep 1
    fi

    hide_cursor
    generic_show_menu "$mod"
}

# Detailed view
generic_view() {
    local mod="$1"
    local key="$2"

    local dat_file
    dat_file=$(mod_prop "$mod" "FILE")

    clear_screen
    draw_header "$(echo "$mod" | tr '[:lower:]' '[:upper:]'): $key"

    if dat_read "$dat_file" "$key"; then
        mod_get_fields "$mod"
        local idx=0
        for field in "${_MOD_FIELDS[@]:1}"; do
            ((idx++))
            local val="${_DAT_FIELDS[$idx]}"
            [[ -z "$val" ]] && continue
            local flabel
            flabel=$(mod_field_prop "$mod" "$field" "LABEL")
            local display_fn
            display_fn=$(mod_field_prop "$mod" "$field" "DISPLAY_FN")
            [[ -n "$display_fn" ]] && val=$($display_fn "$val")
            echo -e "${WHITE}$flabel:${NC} $val"
        done
    fi

    echo -e "\n${DIM}$T_PRESS_KEY${NC}"
    read -n 1 -s
    hide_cursor
    LAST_MENU=""
}

# Entry action: exit mn and run the command
_mod_entry_run() {
    local mod="$1"
    local key="$2"
    local run_fn
    run_fn=$(mod_prop "$mod" "RUN_FN")
    if [[ -n "$run_fn" ]]; then
        $run_fn "$key" > "$MN_RUN_FILE"
    else
        echo "$key" > "$MN_RUN_FILE"
    fi
    cleanup
}

# Default entry action (view)
_mod_entry_view() {
    local mod="$1"
    local key="$2"
    local view_fn
    view_fn=$(mod_prop "$mod" "VIEW_FN")
    if [[ -n "$view_fn" ]]; then
        $view_fn "$key"
    else
        generic_view "$mod" "$key"
    fi
}
