# Kali Linux Zsh overrides
[ -f ~/.aliases ] && . ~/.aliases
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi