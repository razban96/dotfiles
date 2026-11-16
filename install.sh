#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%d.%m.%Y_%H.%M.%S)"
VSCODE_USER_DIR="$HOME/.config/Code/User"

read -rp "This script will link Linux configs to $DOTFILES_DIR. Continue? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

link_with_backup() {
    local target="$1"
    local link_path="$2"

    if [[ ! -e "$target" ]]; then
        echo "[SKIP] Source missing: $target"
        return
    fi

    mkdir -p "$(dirname "$link_path")"

    if [[ -L "$link_path" && "$(readlink -f "$link_path")" == "$(readlink -f "$target")" ]]; then
        echo "[OK] Already linked: $link_path"
        return
    fi

    if [[ -e "$link_path" || -L "$link_path" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$link_path" "$BACKUP_DIR/"
        echo "[BACKUP] Moved existing $(basename "$link_path") -> $BACKUP_DIR"
    fi

    ln -s "$target" "$link_path"
    echo "[LINKED] $link_path -> $target"
}

echo -e "\nSetting up Common configurations..."
link_with_backup "$DOTFILES_DIR/common/git/.gitconfig"        "$HOME/.gitconfig"
link_with_backup "$DOTFILES_DIR/common/git/.gitignore_global" "$HOME/.gitignore_global"
link_with_backup "$DOTFILES_DIR/common/code/.clang-format"    "$HOME/.clang-format"

for file in .bashrc .bash_profile .bash_aliases .bash_logout; do
    link_with_backup "$DOTFILES_DIR/common/bash/$file" "$HOME/$file"
done

echo -e "\nSetting up Linux-specific configurations..."
if [[ -d "$DOTFILES_DIR/linux" ]]; then
    for file in .zshrc .aliases; do
        link_with_backup "$DOTFILES_DIR/linux/$file" "$HOME/$file"
    done
fi

if command -v code >/dev/null 2>&1; then
    echo -e "\nSetting up VS Code configurations..."
    link_with_backup "$DOTFILES_DIR/common/vscode/settings.json"    "$VSCODE_USER_DIR/settings.json"
    link_with_backup "$DOTFILES_DIR/common/vscode/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
    link_with_backup "$DOTFILES_DIR/common/vscode/snippets"         "$VSCODE_USER_DIR/snippets"

    EXT_FILE="$DOTFILES_DIR/common/vscode/extensions.txt"
    if [[ -f "$EXT_FILE" ]]; then
        echo -e "\nInstalling VS Code Extensions..."
        while IFS= read -r ext || [[ -n "$ext" ]]; do
            ext="$(echo "$ext" | xargs)"
            [[ -z "$ext" || "$ext" == \#* ]] && continue
            code --install-extension "$ext" --force
        done < "$EXT_FILE"
    fi
fi

echo -e "\nDotfiles installation completed successfully."