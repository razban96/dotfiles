# dotfiles

Modular, cross-platform configuration repository and interactive deployment scripts for **Windows 11** and **Kali Linux**, designed around a strict `C:` / `D:` drive separation strategy.

## Repository Architecture

```text
C:\dotfiles\
├── common\                  # Shared cross-platform configurations
│   ├── bash\                # .bashrc, .bash_profile, .minttyrc
│   ├── code\                # .clang-format (C++ style rules)
│   ├── git\                 # .gitconfig, .gitignore_global
│   ├── shell\               # .aliases (shared shell shorthand commands)
│   └── starship\            # starship.toml (cross-shell prompt)
├── windows\                 # Windows 11 specific configurations
│   ├── manifests\           # winget-packages.json (exported system apps)
│   ├── powershell\          # Microsoft.PowerShell_profile.ps1
│   └── terminal\            # Windows Terminal settings.json
├── linux\                   # Kali Linux specific configurations
│   ├── manifests\           # apt-packages.txt
│   ├── tmux\                # .tmux.conf
│   └── .zshrc               # Zsh configuration
├── .gitattributes           # Enforces LF on shell/dotfiles and CRLF on .ps1
├── .gitignore               # Ignores local backups and sensitive credentials
├── backup.ps1               # Interactive backup & WinGet manifest exporter
├── install.ps1              # Interactive Windows 11 symlink installer
├── setup-packages.ps1       # Automated WinGet package restorer
└── install.sh               # Interactive Kali Linux symlink installer
```
