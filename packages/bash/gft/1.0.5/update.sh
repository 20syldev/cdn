#!/bin/sh

# gft updater
# Usage: curl -fsSL https://cdn.sylvain.sh/bash/gft@latest/update.sh | sh

set -e

CDN="https://cdn.sylvain.sh/bash"
VERSION="$(curl -fsSL "${CDN}/gft@latest" | grep -o '"version": *"[^"]*"' | head -1 | cut -d'"' -f4)"
if [ -z "$VERSION" ]; then
    printf "${RED}Failed to fetch version${NC}\n"
    exit 1
fi

GFT_DIR="$HOME/.config/gft"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;94m'
CYAN='\033[1;36m'
NC='\033[0m'

printf "${BLUE}gft %s update${NC}\n\n" "$VERSION"

if [ ! -d "$GFT_DIR" ]; then
    printf "${RED}gft is not installed. Run the installer first.${NC}\n"
    exit 1
fi

# ─── Update gft ─────────────────────────────────────────────────────

if [ -f "./gft" ]; then
    cp "./gft" "$GFT_DIR/gft"
    chmod +x "$GFT_DIR/gft"
    printf "${GREEN}gft updated (local)${NC}\n"
elif curl -fsSL "${CDN}/gft@${VERSION}/gft" -o "$GFT_DIR/gft"; then
    chmod +x "$GFT_DIR/gft"
    printf "${GREEN}gft updated${NC}\n"
else
    printf "${RED}Download failed${NC}\n"
    exit 1
fi

echo "$VERSION" > "$GFT_DIR/VERSION"

# ─── Update completions ─────────────────────────────────────────────

for comp_dir in /usr/share/bash-completion/completions "$HOME/.local/share/bash-completion/completions"; do
    if [ -f "$comp_dir/gft" ]; then
        if [ -f "./completions/gft.bash" ]; then
            cp "./completions/gft.bash" "$comp_dir/gft"
        else
            curl -fsSL "${CDN}/gft@${VERSION}/completions/gft.bash" -o "$comp_dir/gft" 2>/dev/null
        fi
        printf "${GREEN}Bash completion updated${NC}\n"
        break
    fi
done

for comp_dir in /usr/share/zsh/vendor-completions "$HOME/.local/share/zsh/site-functions"; do
    if [ -f "$comp_dir/_gft" ]; then
        if [ -f "./completions/_gft" ]; then
            cp "./completions/_gft" "$comp_dir/_gft"
        else
            curl -fsSL "${CDN}/gft@${VERSION}/completions/_gft" -o "$comp_dir/_gft" 2>/dev/null
        fi
        printf "${GREEN}Zsh completion updated${NC}\n"
        break
    fi
done

# ─── Update manpage ─────────────────────────────────────────────────

for man_dir in /usr/local/share/man/man1 "$HOME/.local/share/man/man1"; do
    if [ -f "$man_dir/gft.1" ]; then
        if [ -f "./gft.1" ]; then
            cp "./gft.1" "$man_dir/gft.1"
        else
            curl -fsSL "${CDN}/gft@${VERSION}/gft.1" -o "$man_dir/gft.1" 2>/dev/null
        fi
        printf "${GREEN}Manpage updated${NC}\n"
        break
    fi
done

# ─── Done ───────────────────────────────────────────────────────────

printf "\n${GREEN}Done!${NC} gft ${CYAN}${VERSION}${NC}\n"
