# Cross-Platform Dotfiles (Windows 10/11 & Kali Linux)

razban96's repository for managing and deploying custom configuration files across Windows 10/11 and Linux environments.

---

## Repository Structure

| Folder / File | Description                                                       | Target Location (Windows) | Target Location (Linux) |
| :------------ | :---------------------------------------------------------------- | :------------------------ | :---------------------- |
| `bash/`       | Bash shell configuration files (`.bashrc`, `.bash_profile`, etc.) | `%USERPROFILE%`           | `~`                     |
| `git/`        | Global Git configuration (`.gitconfig`, `.gitignore_global`)      | `%USERPROFILE%`           | `~`                     |
| `vscode/`     | VS Code settings, keybindings, snippets, and `extensions.txt`     | `%APPDATA%\Code\User`     | `~/.config/Code/User`   |
| `backup.ps1`  | Backs up local Windows configurations into this repository        | N/A                       | N/A                     |
| `install.ps1` | Creates symlinks and installs VS Code extensions on Windows 11    | N/A                       | N/A                     |
| `install.sh`  | Creates symlinks and installs VS Code extensions on Linux         | N/A                       | N/A                     |

---

## Initialization & Safety Logic

The installation scripts handle both fresh system setups and existing environments automatically:

1. **No Existing Configs:** If a configuration file does not exist in your users home directory, the script links the file directly from this repository.
2. **Existing Configs:** If a configuration file already exists as a standard file (not a symlink), the script creates a european-like-timestamped backup directory (e.g., `~/dotfiles_backup_DD.MM.YYYY_HH.mm.ss`) and moves your existing files there before creating the new symbolic links.

---

## Installation Guide

### Step 1: Clone the Repository

Open your terminal or command prompt and run:

```bash
git clone [https://github.com/razban96/dotfiles.git](https://github.com/razban96/dotfiles.git) ~/dotfiles
cd ~/dotfiles
```

---

### Step 2: Run OS-Specific Installation Script

#### Option A: Windows 10/11 (PowerShell)

1. **Enable Symbolic Links:** Enable **Developer Mode** in Windows Settings (_Settings > System > Advanced > For developers > Developer Mode_) OR run PowerShell as Administrator.
2. **Execution Policy:** If PowerShell restricts running local scripts, adjust the policy for your current session:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
```

3. **Execute Installation:**

```powershell
.\install.ps1
```

#### Option B: Kali Linux / Debian Linux (Bash)

1. **Grant Permissions:** Make the shell script executable:

```bash
chmod +x install.sh
```

2. **Execute Installation:**

```bash
./install.sh
```

---

## Maintenance & Backup Workflow

To update this repository with new local settings from your Windows machine (such as new VS Code extensions, snippets, or git aliases) and push them to GitHub:

1. **Run Backup Script:**

```powershell
.\backup.ps1
```

2. **Commit and Push:**

```bash
git status
git add .
git commit -m "Update configurations"
git push origin main
```

---

## Troubleshooting & Notes

- **Symlink Privilege Error (Windows):** If you receive a permission error while creating symlinks, verify that Windows Developer Mode is enabled or re-run PowerShell as Administrator.
- **VS Code CLI:** Ensure VS Code is added to your system `PATH` so `code --install-extension` functions properly during script execution.
- **Git Bash Usage:** On Windows, `install.ps1` automatically symlinks `.bashrc` into your `%USERPROFILE%`, making your custom aliases and prompt immediately active inside Git Bash.

---

## Quick Reference Summary

| Task                | Platform      | Primary Command                                                 | Repository Link / Location                                    |
| :------------------ | :------------ | :-------------------------------------------------------------- | :------------------------------------------------------------ |
| **Clone Repo**      | All           | `git clone https://github.com/razban96/dotfiles.git ~/dotfiles` | [razban96/dotfiles](https://github.com/razban96/dotfiles.git) |
| **Install Configs** | Windows 10/11 | `.\install.ps1`                                                 | Executed inside `~/dotfiles`                                  |
| **Install Configs** | Linux         | `chmod +x install.sh && ./install.sh`                           | Executed inside `~/dotfiles`                                  |
| **Backup Configs**  | Windows 10/11 | `.\backup.ps1`                                                  | Executed inside `~/dotfiles`                                  |
| **Push Updates**    | All           | `git add . && git commit -m "..." && git push`                  | Pushes local changes to GitHub                                |
