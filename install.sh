#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%d.%m.%Y_%H.%M.%S)"

link_with_backup() {
    local target="$1"
    local link_path="$2"

    if [[ ! -e "$target" ]]; then
        echo "  [SKIP] Source missing: $target"
        return
    fi

    mkdir -p "$(dirname "$link_path")"

    if [[ -L "$link_path" && "$(readlink -f "$link_path")" == "$(readlink -f "$target")" ]]; then
        echo "  [OK] Already linked: $link_path"
        return
    fi

    if [[ -e "$link_path" || -L "$link_path" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$link_path" "$BACKUP_DIR/"
        echo "  [BACKUP] Moved existing $(basename "$link_path") -> $BACKUP_DIR"
    fi

    ln -s "$target" "$link_path"
    echo "  [LINKED] $link_path -> $target"
}

install_git() {
    echo -e "\n--> Installing [Common] git..."
    link_with_backup "$DOTFILES_DIR/common/git/.gitconfig"        "$HOME/.gitconfig"
    link_with_backup "$DOTFILES_DIR/common/git/.gitignore_global" "$HOME/.gitignore_global"
}

install_code() {
    echo -e "\n--> Installing [Common] code (.clang-format)..."
    link_with_backup "$DOTFILES_DIR/common/code/.clang-format" "$HOME/.clang-format"
}

install_shell() {
    echo -e "\n--> Installing [Common] shell (.aliases)..."
    link_with_backup "$DOTFILES_DIR/common/shell/.aliases" "$HOME/.aliases"
    # Append source hook to existing Kali ~/.bashrc instead of overwriting Kali's prompt/completions
    if [[ -f "$HOME/.bashrc" ]] && ! grep -q "starship init bash" "$HOME/.bashrc"; then
        printf '\n[ -f ~/.aliases ] && . ~/.aliases\ncommand -v starship &>/dev/null && eval "$(starship init bash)"\n' >> "$HOME/.bashrc"
        echo "  [APPENDED] Aliases & Starship hooks added to existing ~/.bashrc"
    fi
}

install_starship() {
    echo -e "\n--> Installing [Common] starship..."
    link_with_backup "$DOTFILES_DIR/common/starship/starship.toml" "$HOME/.config/starship.toml"
}

install_linux_git() {
    echo -e "\n--> Installing [Linux] git-local..."
    link_with_backup "$DOTFILES_DIR/linux/git/.gitconfig.local" "$HOME/.gitconfig.local"
}

install_tmux() {
    echo -e "\n--> Installing [Linux] tmux..."
    link_with_backup "$DOTFILES_DIR/linux/tmux/.tmux.conf" "$HOME/.tmux.conf"
}

install_zsh() {
    echo -e "\n--> Installing [Linux] zsh..."
    link_with_backup "$DOTFILES_DIR/linux/.zshrc" "$HOME/.zshrc"
}

install_all_common() {
    install_git
    install_code
    install_shell
    install_starship
}

install_all_linux() {
    install_linux_git
    install_tmux
    install_zsh
}

read -rp $'\nDotfiles Install: [A] Install Everything, [S] Select Modules, [0] Exit: ' mode
case "${mode^^}" in
    0) exit 0 ;;
    A)
        install_all_common
        install_all_linux
        echo -e "\nAll modules installed."
        exit 0
        ;;
    S)
        while true; do
            cat << 'EOF'

=== Select Module to Install ===
  [C] All Common modules
  [L] All Linux modules
  [1] [Common] git (.gitconfig, .gitignore_global)
  [2] [Common] code (.clang-format)
  [3] [Common] shell (.aliases + source hooks)
  [4] [Common] starship (starship.toml)
  [5] [Linux]  git-local (.gitconfig.local)
  [6] [Linux]  tmux (.tmux.conf)
  [7] [Linux]  zsh (.zshrc)
  [0] Exit
EOF
            read -rp $'\nEnter choice: ' choice
            case "${choice^^}" in
                0) break ;;
                C) install_all_common ;;
                L) install_all_linux ;;
                1) install_git ;;
                2) install_code ;;
                3) install_shell ;;
                4) install_starship ;;
                5) install_linux_git ;;
                6) install_tmux ;;
                7) install_zsh ;;
                *) echo "Invalid selection." ;;
            esac
        done
        ;;
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac