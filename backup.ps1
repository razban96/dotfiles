# Backup script for Windows 11 dotfiles git, vscode, bash

$BackupDir = "$HOME\dotfiles"

# 1. Create directory structure
New-Item -ItemType Directory -Force -Path "$BackupDir\vscode" | Out-Null
New-Item -ItemType Directory -Force -Path "$BackupDir\git" | Out-Null
New-Item -ItemType Directory -Force -Path "$BackupDir\bash" | Out-Null

# 2. Copy Git files
if (Test-Path "$HOME\.gitconfig") {
    Copy-Item "$HOME\.gitconfig" -Destination "$BackupDir\git\.gitconfig" -Force
    Write-Host "Backed up .gitconfig"
}
if (Test-Path "$HOME\.gitignore_global") {
    Copy-Item "$HOME\.gitignore_global" -Destination "$BackupDir\git\.gitignore_global" -Force
    Write-Host "Backed up .gitignore_global"
}

# 3. Copy VS Code files
$VSCodeUserPath = "$env:APPDATA\Code\User"
if (Test-Path "$VSCodeUserPath\settings.json") {
    Copy-Item "$VSCodeUserPath\settings.json" -Destination "$BackupDir\vscode\settings.json" -Force
    Write-Host "Backed up VS Code settings.json"
}
if (Test-Path "$VSCodeUserPath\keybindings.json") {
    Copy-Item "$VSCodeUserPath\keybindings.json" -Destination "$BackupDir\vscode\keybindings.json" -Force
    Write-Host "Backed up VS Code keybindings.json"
}
if (Test-Path "$VSCodeUserPath\snippets") {
    Copy-Item "$VSCodeUserPath\snippets" -Destination "$BackupDir\vscode\snippets" -Recurse -Force
    Write-Host "Backed up VS Code snippets"
}

# 4. Export VS Code extensions list
code --list-extensions > "$BackupDir\vscode\extensions.txt"
Write-Host "Exported VS Code extensions list"

# 5. Copy Bash files
$BashFiles = @(".bashrc", ".bash_profile", ".bash_aliases", ".bash_logout")
foreach ($File in $BashFiles) {
    if (Test-Path "$HOME\$File") {
        Copy-Item "$HOME\$File" -Destination "$BackupDir\bash\$File" -Force
        Write-Host "Backed up $File"
    }
}

Write-Host "Backup process completed successfully."
