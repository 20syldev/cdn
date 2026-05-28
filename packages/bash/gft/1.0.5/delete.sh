#!/bin/sh

# gft uninstaller
# Usage: curl -fsSL https://cdn.sylvain.sh/bash/gft@latest/delete.sh | sh

set -e

GFT_DIR="$HOME/.config/gft"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;94m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

printf "${BLUE}gft uninstaller${NC}\n\n"

if [ ! -d "$GFT_DIR" ]; then
    printf "${YELLOW}gft is not installed.${NC}\n"
    exit 0
fi

# ─── Confirmation ───────────────────────────────────────────────────

printf "${RED}This will remove gft.${NC}\n"
printf "${CYAN}Continue? [y/N]:${NC} "
read -r CONFIRM < /dev/tty
case "$CONFIRM" in
    y|Y|yes|YES|oui|OUI) ;;
    *) printf "${BLUE}Cancelled.${NC}\n"; exit 0 ;;
esac

printf "\n"

# ─── Remove symlinks ───────────────────────────────────────────────

for bin_dir in /usr/local/bin "$HOME/.local/bin" "$HOME/bin"; do
    if [ -L "$bin_dir/gft" ]; then
        rm -f "$bin_dir/gft"
        printf "${GREEN}Removed symlink:${NC} %s/gft\n" "$bin_dir"
    fi
    if [ -L "$bin_dir/gfv" ]; then
        rm -f "$bin_dir/gfv"
        printf "${GREEN}Removed symlink:${NC} %s/gfv\n" "$bin_dir"
    fi
done

# ─── Remove config directory ───────────────────────────────────────

rm -f "$GFT_DIR/gft"
rm -f "$GFT_DIR/VERSION"
rm -rf "$GFT_DIR/cache"
rmdir "$GFT_DIR" 2>/dev/null && printf "${GREEN}Removed:${NC} %s\n" "$GFT_DIR"

# ─── Remove completions ────────────────────────────────────────────

for comp in /usr/share/bash-completion/completions/gft "$HOME/.local/share/bash-completion/completions/gft"; do
    if [ -f "$comp" ]; then
        rm -f "$comp"
        printf "${GREEN}Removed:${NC} %s\n" "$comp"
    fi
done

for comp in /usr/share/zsh/vendor-completions/_gft "$HOME/.local/share/zsh/site-functions/_gft"; do
    if [ -f "$comp" ]; then
        rm -f "$comp"
        printf "${GREEN}Removed:${NC} %s\n" "$comp"
    fi
done

# ─── Remove manpage ────────────────────────────────────────────────

for man in /usr/local/share/man/man1/gft.1 "$HOME/.local/share/man/man1/gft.1"; do
    if [ -f "$man" ]; then
        rm -f "$man"
        printf "${GREEN}Removed:${NC} %s\n" "$man"
    fi
done

# ─── Clean PATH from shell config ──────────────────────────────────

for rc in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && grep -q "# Added by gft installer" "$rc"; then
        sed -i '/# Added by gft installer/d;/export PATH=.*gft/d' "$rc"
        printf "${GREEN}Cleaned:${NC} %s\n" "$rc"
    fi
done

# ─── Done ───────────────────────────────────────────────────────────

printf "\n${GREEN}Done!${NC} gft has been uninstalled.\n"
printf "${YELLOW}Reload your shell to apply changes.${NC}\n"
