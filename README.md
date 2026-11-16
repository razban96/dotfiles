# dotfiles

Cross-platform configuration files and bootstrap scripts for **Windows 11** and **Kali Linux**, paired with a clean `C:` / `D:` drive separation strategy.

## Repository Architecture

```text
C:\dotfiles\
├── common\                  # Shared cross-platform configurations
│   ├── bash\                # .bashrc, .bash_profile, .minttyrc
│   ├── code\                # .clang-format (C++ style rules)
│   ├── git\                 # .gitconfig, .gitignore_global
│   └── vscode\              # settings.json, keybindings.json, extensions.txt
├── windows\                 # Windows 11 specific configurations
│   ├── powershell\          # Microsoft.PowerShell_profile.ps1
│   └── terminal\            # Windows Terminal settings.json
├── linux\                   # Kali Linux specific overrides (.zshrc, .aliases)
├── .gitattributes           # Enforces LF on shell/dotfiles and CRLF on .ps1
├── backup.ps1               # Exports VS Code extensions & repairs unlinked configs
├── install.ps1              # Idempotent Windows 11 symlink bootstrapper
└── install.sh               # Idempotent Kali Linux symlink bootstrapper