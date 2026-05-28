#!/bin/sh

# mn installer
# Usage: curl -fsSL https://cdn.sylvain.sh/bash/mn@latest/install.sh | sh

set -e

CDN="https://cdn.sylvain.sh/bash"
VERSION="$(curl -fsSL "${CDN}/mn@latest" | grep -o '"version": *"[^"]*"' | head -1 | cut -d'"' -f4)"
if [ -z "$VERSION" ]; then
    printf "${RED}Failed to fetch version${NC}\n"
    exit 1
fi
MN_DIR="$HOME/.config/mn"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;94m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

printf "${BLUE}mn %s installer${NC}\n" "$VERSION"
printf "\n"

# ─── Language / Langue ───────────────────────────────────────────────

curl -fsSL "${CDN}/mn@${VERSION}/lang/index" -o /tmp/mn_lang_index 2>/dev/null || true
if [ ! -s /tmp/mn_lang_index ]; then
    printf "fr:Français\nen:English\n" > /tmp/mn_lang_index
fi

printf "${BLUE}Language / Langue:${NC}\n"
_i=1
while IFS=: read -r _code _name; do
    printf "  %s) %s\n" "$_i" "$_name"
    _i=$((_i + 1))
done < /tmp/mn_lang_index
printf "${CYAN}Choix / Choice [1]:${NC} "
read -r LANG_CHOICE < /dev/tty
[ -z "$LANG_CHOICE" ] && LANG_CHOICE=1
LANG_SETTING=$(sed -n "${LANG_CHOICE}p" /tmp/mn_lang_index 2>/dev/null | cut -d: -f1)
[ -z "$LANG_SETTING" ] && LANG_SETTING="en"
printf "\n"

# ─── Source language for subsequent prompts ───────────────────────────

curl -fsSL "${CDN}/mn@${VERSION}/lang/${LANG_SETTING}.sh" -o /tmp/mn_lang.sh 2>/dev/null || true
[ -f /tmp/mn_lang.sh ] && . /tmp/mn_lang.sh

# ─── Editor ──────────────────────────────────────────────────────────

printf "${BLUE}${T_CONFIG_EDITOR_TITLE}:${NC}\n"
printf "  1) vi\n"
printf "  2) vim\n"
printf "  3) nano\n"
printf "  4) zed\n"
printf "  5) VS Code (code -n)\n"
printf "  6) ${T_CONFIG_EDITOR_CUSTOM}\n"
printf "${CYAN}${T_CHOICE} [1]:${NC} "
read -r EDITOR_CHOICE < /dev/tty
case "$EDITOR_CHOICE" in
    2|vim) EDITOR_SETTING="vim" ;;
    3|nano) EDITOR_SETTING="nano" ;;
    4|zed) EDITOR_SETTING="zed" ;;
    5|code) EDITOR_SETTING="code -n" ;;
    6)
        printf "${CYAN}${T_CONFIG_EDITOR_CUSTOM}:${NC} "
        read -r EDITOR_SETTING < /dev/tty
        ;;
    *) EDITOR_SETTING="vi" ;;
esac
printf "\n"

# ─── Create directories ───────────────────────────────────────────────

mkdir -p "$MN_DIR/lib" "$MN_DIR/modules" "$MN_DIR/data" "$MN_DIR/docs" "$MN_DIR/lang"
printf "${BLUE}Config directory:${NC} %s\n" "$MN_DIR"

# ─── Download mn ──────────────────────────────────────────────────────

printf "${BLUE}Downloading mn...${NC}\n"

echo "$VERSION" > "$MN_DIR/VERSION"

if curl -fsSL "${CDN}/mn@${VERSION}/mn" -o "$MN_DIR/mn"; then
    chmod +x "$MN_DIR/mn"
    printf "${GREEN}mn downloaded${NC}\n"
else
    printf "${RED}Download failed${NC}\n"
    exit 1
fi

# ─── Download lib/ ────────────────────────────────────────────────────

for lib in core crud dat module ui; do
    if curl -fsSL "${CDN}/mn@${VERSION}/lib/${lib}.sh" -o "$MN_DIR/lib/${lib}.sh" 2>/dev/null; then
        printf "${GREEN}lib/${lib}.sh downloaded${NC}\n"
    fi
done

# ─── Download modules/ ────────────────────────────────────────────────

for mod in alias config connexions docs funcs repos; do
    if curl -fsSL "${CDN}/mn@${VERSION}/modules/${mod}.sh" -o "$MN_DIR/modules/${mod}.sh" 2>/dev/null; then
        printf "${GREEN}modules/${mod}.sh downloaded${NC}\n"
    fi
done

# ─── Download lang/ ───────────────────────────────────────────────────

while IFS=: read -r _code _name; do
    [ -z "$_code" ] && continue
    if curl -fsSL "${CDN}/mn@${VERSION}/lang/${_code}.sh" -o "$MN_DIR/lang/${_code}.sh" 2>/dev/null; then
        printf "${GREEN}lang/${_code}.sh downloaded${NC}\n"
    fi
done < /tmp/mn_lang_index
rm -f /tmp/mn_lang_index /tmp/mn_lang.sh

# ─── Language setting ─────────────────────────────────────────────────

echo "$LANG_SETTING" > "$MN_DIR/.lang"
printf "${GREEN}Language set to: ${LANG_SETTING}${NC}\n"

echo "$EDITOR_SETTING" > "$MN_DIR/.editor"
printf "${GREEN}Editor set to: ${EDITOR_SETTING}${NC}\n"

# ─── Init data files ──────────────────────────────────────────────────

for dat in aliases connexions functions repos; do
    [ ! -f "$MN_DIR/data/${dat}.dat" ] && touch "$MN_DIR/data/${dat}.dat"
done

# ─── Install directory ───────────────────────────────────────────────

if [ -w "/usr/local/bin" ]; then
    INSTALL_DIR="/usr/local/bin"
elif [ -w "$HOME/.local/bin" ]; then
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
else
    INSTALL_DIR="$HOME/bin"
    mkdir -p "$INSTALL_DIR"
fi

printf "${BLUE}Install directory:${NC} %s\n" "$INSTALL_DIR"

ln -sf "$MN_DIR/mn" "$INSTALL_DIR/mn"
printf "${GREEN}mn installed${NC}\n"

# ─── PATH ────────────────────────────────────────────────────────────

case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
        SHELL_CONFIG=""
        if [ -n "${ZSH_VERSION:-}" ]; then
            SHELL_CONFIG="$HOME/.zshrc"
        elif [ -f "$HOME/.bashrc" ]; then
            SHELL_CONFIG="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            SHELL_CONFIG="$HOME/.bash_profile"
        elif [ -f "$HOME/.profile" ]; then
            SHELL_CONFIG="$HOME/.profile"
        fi

        if [ -n "$SHELL_CONFIG" ]; then
            printf "\n# Added by mn installer\nexport PATH=\"%s:\$PATH\"\n" "$INSTALL_DIR" >> "$SHELL_CONFIG"
            printf "${YELLOW}PATH updated in %s — reload your shell${NC}\n" "$SHELL_CONFIG"
        else
            printf "${YELLOW}Add to your shell config: export PATH=\"%s:\$PATH\"${NC}\n" "$INSTALL_DIR"
        fi
        ;;
esac

# ─── Done ────────────────────────────────────────────────────────────

printf "\n${GREEN}Done!${NC} Run: ${CYAN}mn${NC}\n"
