#!/bin/bash
# Linux Dotfiles Installation Script for git, vscode, bash

DOTFILES_DIR="$HOME/dotfiles"
TIMESTAMP=$(date +"%d.%m.%Y_%H.%M.%S")
BACKUP_DIR="$HOME/dotfiles_backup_$TIMESTAMP"

# 1. Interactive Safety Prompt
read -p "This script will link system configs to $DOTFILES_DIR. Continue? (y/N) " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "\e[33mOperation cancelled by user.\e[0m"
    exit 1
fi

# 2. Backup Helper Function
link_with_backup() {
    local LINK_PATH=$1
    local TARGET_PATH=$2

    if [ ! -e "$TARGET_PATH" ]; then
        echo -e "\e[31mSource target missing: $TARGET_PATH\e[0m"
        return
    fi

    if [ -e "$LINK_PATH" ] || [ -L "$LINK_PATH" ]; then
        if [ ! -L "$LINK_PATH" ]; then
            mkdir -p "$BACKUP_DIR"
            mv "$LINK_PATH" "$BACKUP_DIR/"
            echo -e "\e[33mBacked up existing $(basename "$LINK_PATH")\e[0m"
        else
            rm "$LINK_PATH"
        fi
    fi

    ln -s "$TARGET_PATH" "$LINK_PATH"
    echo -e "\e[32mSymlink created: $LINK_PATH\e[0m"
}

# 3. Create Bash Symlinks
echo -e "\n\e[36mSetting up Bash configurations...\e[0m"
for file in .bashrc .bash_profile .bash_aliases .bash_logout; do
    link_with_backup "$HOME/$file" "$DOTFILES_DIR/bash/$file"
done

# 4. Create Git Symlinks
echo -e "\n\e[36mSetting up Git configurations...\e[0m"
link_with_backup "$HOME/.gitconfig" "$DOTFILES_DIR/git/.gitconfig"
link_with_backup "$HOME/.gitignore_global" "$DOTFILES_DIR/git/.gitignore_global"

# 5. Create VS Code Symlinks & Install Extensions
VSCODE_PATH="$HOME/.config/Code/User"
if [ -d "$(dirname "$VSCODE_PATH")" ]; then
    echo -e "\n\e[36mSetting up VS Code configurations...\e[0m"
    mkdir -p "$VSCODE_PATH"
    link_with_backup "$VSCODE_PATH/settings.json" "$DOTFILES_DIR/vscode/settings.json"
    link_with_backup "$VSCODE_PATH/keybindings.json" "$DOTFILES_DIR/vscode/keybindings.json"
    link_with_backup "$VSCODE_PATH/snippets" "$DOTFILES_DIR/vscode/snippets"

    EXT_FILE="$DOTFILES_DIR/vscode/extensions.txt"
    if [ -f "$EXT_FILE" ]; then
        echo -e "\n\e[36mInstalling VS Code Extensions...\e[0m"
        while read -r ext; do
            if [[ -n "$ext" && ! "$ext" =~ ^# ]]; then
                code --install-extension "$ext" --force
            fi
        done < "$EXT_FILE"
    fi
fi

echo -e "\n\e[32mDotfiles installation completed successfully.\e[0m"
