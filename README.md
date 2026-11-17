# dotfiles

Modular, cross-platform configuration repository and interactive deployment scripts for **Windows 11** and **Kali Linux**, designed around a strict `C:` / `D:` drive separation strategy and portable `$PSScriptRoot` / `$BASH_SOURCE` resolution.

---

## Repository Architecture

```text
dotfiles/
├── common/                  # Shared cross-platform configurations
│   ├── bash/                # .bashrc, .bash_profile (sources ~/.aliases & Starship)
│   ├── code/                # .clang-format (C++ style rules)
│   ├── git/                 # .gitconfig (core identity + includes ~/.gitconfig.local), .gitignore_global
│   ├── shell/               # .aliases (shared shell shorthand commands)
│   └── starship/            # starship.toml (cross-shell prompt)
├── windows/                 # Windows 11 specific configurations
│   ├── bash/                # .minttyrc (Git Bash / MSYS2 terminal settings)
│   ├── git/                 # .gitconfig.local (autocrlf=true, filemode=false, fscache, CLion diff/editor)
│   ├── manifests/           # winget-packages.json (exported system apps)
│   ├── powershell/          # Microsoft.PowerShell_profile.ps1 (Starship init & PS helpers)
│   └── terminal/            # Windows Terminal settings.json
├── linux/                   # Kali Linux specific configurations
│   ├── git/                 # .gitconfig.local (autocrlf=input, filemode=true, vim)
│   ├── manifests/           # apt-packages.txt
│   ├── tmux/                # .tmux.conf
│   └── .zshrc               # Zsh configuration (sources ~/.aliases & Starship)
├── .gitattributes           # Enforces LF on shell/dotfiles and CRLF on .ps1
├── .gitignore               # Ignores local backups and sensitive credentials
├── install.ps1              # Interactive Windows 11 symlink installer
├── backup.ps1               # Interactive Windows 11 sync & WinGet manifest exporter
├── setup-packages.ps1       # Automated WinGet package restorer
└── install.sh               # Interactive Kali Linux symlink installer
```

### Why OS-Specific Git & Shell Splits Exist
* **Git (`common/git/.gitconfig` + `~/.gitconfig.local`):** Keeps user identity and global ignores shared while isolating Windows-only settings (`autocrlf = true`, `filemode = false`, `fscache = true`, `editor = clion --wait`) from Linux settings (`autocrlf = input`, `filemode = true`, `editor = vim`). This guarantees Linux checkouts never suffer `CRLF` line-ending corruption or stripped `+x` executable permissions.
* **Mintty (`windows/bash/.minttyrc`):** Scoped strictly to `windows/` because Mintty is specific to Git Bash / MSYS2 on Windows.
* **Non-Destructive Linux `.bashrc`:** On Kali Linux, `install.sh` appends source hooks for `~/.aliases` and `starship` into your existing `~/.bashrc` rather than overwriting Kali's native prompt, completions, and aliases.

---

## Workspace & Drive Layout (`C:` vs `D:`)

System configurations stay version-controlled in `C:\dotfiles`, while active codebases, third-party tools, creative assets, and heavy caches live isolated on `D:` to prevent OneDrive sync conflicts and preserve `C:` SSD capacity:

```text
C:\
├── dotfiles\                # Git-tracked configs + XDG_CONFIG_HOME (C:\dotfiles\.config)
└── Users\<User>\            # Kept clean via symbolic links pointing into C:\dotfiles

D:\
├── dev\
│   ├── projects\            # Personal & university Git repositories
│   ├── sandbox\             # Scratch scripts, prototypes, and migration utilities
│   ├── tools\
│   │   ├── bin\             # Standalone portable executables (added to User PATH)
│   │   └── repos\           # Cloned third-party GitHub tools & MCP servers
│   └── .cache\              # Offloaded caches (OLLAMA_MODELS, UV, PIP, npm)
├── Uni\                     # Non-code university PDFs, lecture notes, and archives
├── Creative\                # Creative projects and scratch/temp directories
├── APPS\                    # Offloaded heavy applications (JetBrains IDEs, VMs)
└── Games\                   # Steam, Epic Games, and standalone game libraries
```

---

## Setup Guide: Windows 11

### Prerequisites
* **PowerShell 7+** (`pwsh`)
* **Administrator Privileges** (required to create NTFS symbolic links unless Windows Developer Mode is enabled under *Settings > System > For developers*)

### 1. Initial Workspace & Environment Setup (Fresh Machine)
Run this once in **PowerShell 7 (Run as Administrator)** to build your `D:\dev` hierarchy, redirect caches off `C:`, and register your portable tools path:

```powershell
# Create standard D:\dev structure
New-Item -ItemType Directory -Force -Path `
    "D:\dev\projects", `
    "D:\dev\sandbox", `
    "D:\dev\tools\bin", `
    "D:\dev\tools\repos", `
    "D:\dev\.cache" | Out-Null

# Redirect XDG configs to C:\dotfiles and heavy tool caches to D:\dev\.cache
[Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", "C:\dotfiles\.config", "User")
[Environment]::SetEnvironmentVariable("XDG_CACHE_HOME", "D:\dev\.cache", "User")
[Environment]::SetEnvironmentVariable("PIP_CACHE_DIR", "D:\dev\.cache\pip", "User")
[Environment]::SetEnvironmentVariable("UV_CACHE_DIR", "D:\dev\.cache\uv", "User")
[Environment]::SetEnvironmentVariable("npm_config_cache", "D:\dev\.cache\npm", "User")

# Add D:\dev\tools\bin to User PATH safely
$userPath = [Environment]::GetEnvironmentVariable("Path", "User") -split ';' | Where-Object { $_ } | Select-Object -Unique
if ($userPath -notcontains "D:\dev\tools\bin") { $userPath += "D:\dev\tools\bin" }
[Environment]::SetEnvironmentVariable("Path", ($userPath -join ';'), "User")
```

### 2. Clone & Link Dotfiles
```powershell
git clone https://github.com/razban96/dotfiles.git C:\dotfiles
cd C:\dotfiles
.\install.ps1
```

### 3. Choosing What to Install (`install.ps1`)
When you run `.\install.ps1`, you are prompted with:
* **`A` (Install Everything):** Links all `common\` and `windows\` configurations at once and exits.
* **`S` (Select Specific Modules):** Opens an interactive loop where you can apply entire groups or single modules one by one until pressing `0`:
  * **`C`** — Install all **Common** modules at once (`git`, `bash`, `code`, `shell`, `starship`)
  * **`W`** — Install all **Windows** modules at once (`git-local`, `powershell`, `terminal`)
  * **`1`** — `git` (`.gitconfig`, `.gitignore_global`)
  * **`2`** — `bash` (`.bashrc`, `.bash_profile`)
  * **`3`** — `code` (`.clang-format`)
  * **`4`** — `shell` (`.aliases`)
  * **`5`** — `starship` (`starship.toml` -> `$HOME\.config\starship.toml`)
  * **`6`** — `git-local` + `.minttyrc` (Windows Git settings & Git Bash terminal config)
  * **`7`** — `powershell` (`Microsoft.PowerShell_profile.ps1` -> `$PROFILE.CurrentUserCurrentHost`)
  * **`8`** — `terminal` (Windows Terminal `settings.json`)
  * **`0`** — Exit the installer

### 4. Restoring & Backing Up Windows Applications
* **Restore apps on a fresh Windows PC (Run as Administrator):**
  ```powershell
  .\setup-packages.ps1
  ```
  Reads `windows\manifests\winget-packages.json`, updates WinGet sources, and batch-installs your tracked applications (`--ignore-unavailable --ignore-versions`).
* **Back up changes or export updated WinGet packages:**
  ```powershell
  .\backup.ps1
  ```
  Choose **`A`** to sync everything, or **`S`** and press **`9`** to overwrite `windows\manifests\winget-packages.json` with your currently installed WinGet apps (`--force --disable-interactivity`), or **`1`**–**`8`** to sync any unlinked local configuration files back into the repo.

---

## Setup Guide: Kali Linux

### 1. Clone & Run the Installer
```bash
git clone https://github.com/razban96/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

### 2. Choosing What to Install (`install.sh`)
Like the Windows installer, `./install.sh` asks whether you want to install everything (`A`) or enter selective mode (`S`):
* **`A` (Install Everything):** Links all `common/` and `linux/` configurations and exits.
* **`S` (Select Specific Modules):** Opens a continuous menu until you press `0`:
  * **`C`** — Install all **Common** modules (`git`, `code`, `shell`, `starship`)
  * **`L`** — Install all **Linux** modules (`git-local`, `tmux`, `zsh`)
  * **`1`** — `git` (`.gitconfig`, `.gitignore_global`)
  * **`2`** — `code` (`.clang-format`)
  * **`3`** — `shell` (links `~/.aliases` and appends `.aliases` + `starship` hooks to `~/.bashrc` without overwriting Kali defaults)
  * **`4`** — `starship` (`starship.toml` -> `~/.config/starship.toml`)
  * **`5`** — `git-local` (`linux/git/.gitconfig.local` -> `~/.gitconfig.local` with `autocrlf=input` & `filemode=true`)
  * **`6`** — `tmux` (`.tmux.conf` -> `~/.tmux.conf`)
  * **`7`** — `zsh` (`.zshrc` -> `~/.zshrc`)
  * **`0`** — Exit the installer

### 3. Installing Core Kali CLI Packages
Install the packages listed in `linux/manifests/apt-packages.txt`:
```bash
sudo apt update && grep -v '^#' ~/dotfiles/linux/manifests/apt-packages.txt | xargs sudo apt install -y
```

---

## How the Scripts React to Existing Files

All scripts resolve their own location dynamically (`$PSScriptRoot` on Windows, `$BASH_SOURCE` on Linux) and follow safe, idempotent rules:
1. **Valid Symlink Already Exists (`[OK]`):** If the target path is already a symbolic link pointing to the exact file inside `dotfiles/`, the script skips it untouched.
2. **Existing Real File or Conflicting Link (`[BACKUP]` -> `[LINKED]`):** Automatically creates `~/dotfiles_backup_<dd.MM.yyyy_HH.mm.ss>/`, moves your existing file there so nothing is ever lost, and creates the new symbolic link.
3. **Missing Source File in Repo (`[SKIP]`):** Prints a warning and moves on cleanly without halting execution.
4. **Broken Symlink Repair (`backup.ps1`):** If an application overwrites a symlink with a regular file on Windows, running `backup.ps1` detects that the file is no longer a reparse point and copies the updated file back into `C:\dotfiles` (`[SYNCED]`) before showing `git status -s`.

---

## Environment Variables Reference (Windows 11)

| Variable | Value | Purpose |
| :--- | :--- | :--- |
| `XDG_CONFIG_HOME` | `C:\dotfiles\.config` | Keeps cross-platform CLI tool configs inside the repo |
| `XDG_CACHE_HOME` | `D:\dev\.cache` | Redirects tool caches off the `C:` drive |
| `OLLAMA_MODELS` | `D:\dev\.cache\ollama` | Stores local LLM weights on `D:` |
| `UV_CACHE_DIR` | `D:\dev\.cache\uv` | Redirects `uv` Python package cache to `D:` |
| `PIP_CACHE_DIR` | `D:\dev\.cache\pip` | Redirects `pip` cache to `D:` |
| `npm_config_cache` | `D:\dev\.cache\npm` | Redirects `npm` cache to `D:` |