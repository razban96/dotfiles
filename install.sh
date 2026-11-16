#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%d.%m.%Y_%H.%M.%S)"

read -rp "Link Linux & Common configs to $DOTFILES_DIR? (y/N): " confirm
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
link_with_backup "$DOTFILES_DIR/common/git/.gitconfig"           "$HOME/.gitconfig"
link_with_backup "$DOTFILES_DIR/common/git/.gitignore_global"    "$HOME/.gitignore_global"
link_with_backup "$DOTFILES_DIR/common/code/.clang-format"       "$HOME/.clang-format"
link_with_backup "$DOTFILES_DIR/common/shell/.aliases"           "$HOME/.aliases"
link_with_backup "$DOTFILES_DIR/common/starship/starship.toml"   "$HOME/.config/starship.toml"

for file in .bashrc .bash_profile; do
    link_with_backup "$DOTFILES_DIR/common/bash/$file" "$HOME/$file"
done

echo -e "\nSetting up Linux-specific configurations..."
link_with_backup "$DOTFILES_DIR/linux/tmux/.tmux.conf" "$HOME/.tmux.conf"
link_with_backup "$DOTFILES_DIR/linux/.zshrc"          "$HOME/.zshrc"

echo -e "\nDotfiles installation completed successfully."