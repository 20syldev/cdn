#!/bin/sh

# mn local update
# Usage: ./update.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION="$(cat "$SCRIPT_DIR/VERSION")"
MN_DIR="$HOME/.config/mn"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;94m'
NC='\033[0m'

printf "${BLUE}mn %s update${NC}\n\n" "$VERSION"

if [ ! -d "$MN_DIR" ]; then
    printf "${RED}mn is not installed. Run ./install.sh first.${NC}\n"
    exit 1
fi

# ─── Update mn ────────────────────────────────────────────────────────

cp "$SCRIPT_DIR/VERSION" "$MN_DIR/VERSION"
cp "$SCRIPT_DIR/mn" "$MN_DIR/mn" && chmod +x "$MN_DIR/mn"
printf "${GREEN}mn updated${NC}\n"

# ─── Update lib/ ──────────────────────────────────────────────────────

for lib in core crud dat module ui; do
    cp "$SCRIPT_DIR/lib/${lib}.sh" "$MN_DIR/lib/${lib}.sh"
    printf "${GREEN}lib/${lib}.sh updated${NC}\n"
done

# ─── Update modules/ ──────────────────────────────────────────────────

for mod in alias config connexions docs funcs repos; do
    cp "$SCRIPT_DIR/modules/${mod}.sh" "$MN_DIR/modules/${mod}.sh"
    printf "${GREEN}modules/${mod}.sh updated${NC}\n"
done

# ─── Update lang/ ─────────────────────────────────────────────────────

for lang in fr en; do
    cp "$SCRIPT_DIR/lang/${lang}.sh" "$MN_DIR/lang/${lang}.sh"
    printf "${GREEN}lang/${lang}.sh updated${NC}\n"
done

# ─── Done ─────────────────────────────────────────────────────────────

printf "\n${GREEN}Done!${NC} Run: ${NC}mn${NC}\n"
