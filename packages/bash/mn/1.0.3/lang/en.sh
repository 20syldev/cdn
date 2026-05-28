#!/bin/bash
# =========================================================
# MN - English translations
# =========================================================

# -------------------- GENERIC -------------------- #

T_OR="or"
T_YES="Yes"
T_NO="No"
T_CONFIRM="Confirm"
T_CANCEL="Cancel"
T_CURRENT="current"
T_PRESS_KEY="[Press any key]"
T_PRESS_KEY_CONTINUE="[Press any key to continue]"
T_CHOICE="Choice"
T_REQUIRED="is required"

# -------------------- CRUD -------------------- #

T_EDIT_PREFIX="EDIT"
T_DEL_PREFIX="DELETE"
T_ADDED="added"
T_UPDATED="updated"
T_DELETED="deleted"
T_KEEP_HINT="empty = keep"
T_PASS_CURRENT="Current password"
T_PASS_KEEP_DEL="empty = keep, '-' = remove"

# -------------------- UI -------------------- #

T_FOOTER_BASE="[↑/↓] Navigate  [R] Return"
T_FOOTER_QUIT="[↑/↓] Navigate  [Q] Quit"
T_FOOTER_CRUD="[E] Edit  [D] Delete  [V] View"
T_FOOTER_ADD="[Enter] Add"
T_FOOTER_SELECT="[Enter] Select"
T_PAGE_INFO="Page"
T_PAGE_CHANGE="[←/→] Change page"

# -------------------- MENUS -------------------- #

T_MENU_TITLE="MN - PERSONAL MANUAL"
T_MENU_CONNEXIONS="CONNEXIONS - SSH / Custom connections"
T_MENU_REPOS="REPOS - GitHub repositories"
T_MENU_ALIAS="ALIAS - Manage aliases"
T_MENU_FUNCS="FUNCS - Manage functions"
T_MENU_DOCS="DOCS - Documentation"
T_MENU_CONFIG="CONFIG - Configuration"
T_MENU_HELP="HELP - Help"
T_MENU_TITLE_CONFIG="CONFIGURATION"
T_MENU_TITLE_DOCS="DOCUMENTATION"

# -------------------- HELP -------------------- #

T_HELP_TITLE="HELP - MN"
T_HELP_USAGE="USAGE"
T_HELP_NAV="NAVIGATION"
T_HELP_FILES="FILES"
T_HELP_CMD_MAIN="Open main menu"
T_HELP_CMD_CONN="Open connections menu"
T_HELP_CMD_REPOS="Open repositories menu"
T_HELP_CMD_ALIAS="Open aliases menu"
T_HELP_CMD_FUNCS="Open functions menu"
T_HELP_CMD_DOCS="Open documentation"
T_HELP_CMD_UPDATE="Update mn"
T_HELP_CMD_UNINSTALL="Uninstall mn"
T_HELP_CMD_HELP="Show this help"
T_HELP_NAV_ARROWS="Navigate in the menu"
T_HELP_NAV_ENTER="Select option"
T_HELP_NAV_BACK="Return to main menu"
T_HELP_NAV_QUIT="Quit"
T_HELP_NAV_ACTIONS="Edit / Delete / View"

# -------------------- ERRORS -------------------- #

T_ERR_UNKNOWN="Unknown option"
T_ERR_HELP_HINT="Use mn help to show help"

# -------------------- MODULE CONNEXIONS -------------------- #

T_CONN_TITLE="CONNEXIONS - SSH / Custom"
T_CONN_TITLE_ADD="ADD A CONNECTION"
T_CONN_NOUN="connection"
T_CONN_ADD_LABEL="Add a connection"
T_CONN_F_LABEL="Label"
T_CONN_F_IP="IP or hostname"
T_CONN_F_DESC="Description"
T_CONN_F_TYPE="Connection type"
T_CONN_F_PASS="Password"
T_CONN_TYPE_SSH="ssh (standard)"
T_CONN_TYPE_CUSTOM="custom"
T_CONN_F_CMD="Custom command"
T_CONN_CONNECTING="Connecting to"

# -------------------- MODULE REPOS -------------------- #

T_REPOS_TITLE="REPOS - GITHUB"
T_REPOS_TITLE_ADD="ADD A REPO"
T_REPOS_NOUN="repo"
T_REPOS_ADD_LABEL="Add a repo"
T_REPOS_F_NAME="Alias name"
T_REPOS_F_PATH="Repo path"
T_REPOS_F_DESC="Description"
T_REPOS_OPENING="Opening"

# -------------------- MODULE ALIAS -------------------- #

T_ALIAS_TITLE="ALIAS"
T_ALIAS_TITLE_ADD="ADD AN ALIAS"
T_ALIAS_NOUN="alias"
T_ALIAS_ADD_LABEL="Add an alias"
T_ALIAS_F_NAME="Alias name"
T_ALIAS_F_CMD="Command"
T_ALIAS_F_DESC="Description"

# -------------------- MODULE FUNCS -------------------- #

T_FUNCS_TITLE="FUNCTIONS"
T_FUNCS_TITLE_ADD="ADD A FUNCTION"
T_FUNCS_NOUN="function"
T_FUNCS_ADD_LABEL="Add a function"
T_FUNCS_F_NAME="Function name"
T_FUNCS_F_DESC="Description"
T_FUNCS_F_TYPE="Type"
T_FUNCS_TYPE_NORMAL="Normal script (executed as command)"
T_FUNCS_TYPE_SHELL="Shell function (sourced, allows exit/cd)"
T_FUNCS_FILE_LABEL="File"
T_FUNCS_SOURCED="sourced in terminal"
T_FUNCS_NOT_FOUND="not found"
T_FUNCS_OPEN_EDITOR="Opening editor for"
T_FUNCS_CONTENT="─── Content ───"
T_FUNCS_CONTENT_END="───────────────"
T_FUNCS_DEL_DAT="Delete entry from functions.dat?"
T_FUNCS_DEL_FILE="Also delete"
T_FUNCS_DEL_BOTH="Entry and file deleted!"
T_FUNCS_DEL_ENTRY="Entry deleted (file kept)"

# -------------------- MODULE CONFIG -------------------- #

T_CONFIG_EDIT_MN="Edit MN"
T_CONFIG_EDIT_ALIASES="Edit ~/.bash_aliases"
T_CONFIG_EDIT_FUNCS="Edit ~/.bash_functions"
T_CONFIG_EDIT_BASHRC="Edit ~/.bashrc"
T_CONFIG_SOURCE="Source all files"
T_CONFIG_LANG="Change language"
T_CONFIG_UNINSTALL="Uninstall mn"
T_CONFIG_UNINSTALL_TITLE="UNINSTALL"
T_CONFIG_UNINSTALL_CONFIRM="Remove mn and all its data?"
T_CONFIG_UNINSTALL_DONE="mn has been uninstalled. Reload your shell."
T_CONFIG_REGEN_TITLE="RELOADING"
T_CONFIG_REGEN_MSG="Regenerating files..."
T_CONFIG_REGEN_DONE="Files regenerated! Sourced automatically when MN closes."
T_CONFIG_LANG_TITLE="LANGUE / LANGUAGE"
T_CONFIG_LANG_CURRENT="Current language"
T_CONFIG_LANG_CHANGED="Language changed. Restart mn to apply."
T_CONFIG_EDITOR="Change editor"
T_CONFIG_EDITOR_TITLE="EDITOR"
T_CONFIG_EDITOR_CURRENT="Current editor"
T_CONFIG_EDITOR_CUSTOM="Custom command"
T_CONFIG_EDITOR_CHANGED="Editor changed."
