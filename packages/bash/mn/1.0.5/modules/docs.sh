#!/bin/bash
# =========================================================
# MN - Module: Documentation
# =========================================================

DOCS_DIR="$MN_DIR/docs"

show_docs_menu() {
    CURRENT_MENU="docs"
    SELECTED_INDEX=0
    USE_PAGINATION=false

    MENU_ITEMS=()
    MENU_ACTIONS=()

    for file in "$DOCS_DIR"/*.md; do
        [[ -f "$file" ]] || continue
        local name
        name=$(basename "$file" .md)
        MENU_ITEMS+=("${name^^}")
        MENU_ACTIONS+=("show_doc_file:::$file")
    done
}

show_doc_file() {
    local file="$1"
    show_cursor
    less -R "$file"
    hide_cursor
    show_docs_menu
}
