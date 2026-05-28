#!/bin/sh

# mn uninstaller
# Usage: curl -fsSL https://cdn.sylvain.sh/bash/mn@latest/delete.sh | sh

set -e

MN_DIR="$HOME/.config/mn"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;94m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

printf "${BLUE}mn uninstaller${NC}\n\n"

if [ ! -d "$MN_DIR" ]; then
    printf "${YELLOW}mn is not installed.${NC}\n"
    exit 0
fi

# ─── Confirmation ────────────────────────────────────────────────────

printf "${RED}This will remove mn and all its data.${NC}\n"
printf "${CYAN}Continue? [y/N]:${NC} "
read -r CONFIRM < /dev/tty
case "$CONFIRM" in
    y|Y|yes|YES|oui|OUI) ;;
    *) printf "${BLUE}Cancelled.${NC}\n"; exit 0 ;;
esac

printf "\n"

# ─── Remove symlink ─────────────────────────────────────────────────

for bin_dir in /usr/local/bin "$HOME/.local/bin" "$HOME/bin"; do
    if [ -L "$bin_dir/mn" ]; then
        rm -f "$bin_dir/mn"
        printf "${GREEN}Removed symlink:${NC} %s/mn\n" "$bin_dir"
    fi
done

# ─── Remove config directory ────────────────────────────────────────

rm -rf "$MN_DIR"
printf "${GREEN}Removed:${NC} %s\n" "$MN_DIR"

# ─── Clean PATH from shell config ───────────────────────────────────

for rc in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && grep -q "# Added by mn installer" "$rc"; then
        sed -i '/# Added by mn installer/d;/export PATH=.*mn/d' "$rc"
        printf "${GREEN}Cleaned:${NC} %s\n" "$rc"
    fi
done

# ─── Clean bash_aliases / bash_functions ─────────────────────────────

if [ -f "$HOME/.bash_functions" ] && grep -q "mn()" "$HOME/.bash_functions"; then
    sed -i '/^mn()/d' "$HOME/.bash_functions"
    printf "${GREEN}Removed mn function from:${NC} ~/.bash_functions\n"
fi

# ─── Done ────────────────────────────────────────────────────────────

printf "\n${GREEN}Done!${NC} mn has been uninstalled.\n"
printf "${YELLOW}Reload your shell to apply changes.${NC}\n"
