# Windows 11 Dotfiles Installation Script for git, vscode, bash

$Path = "$HOME\dotfiles"
$VSCodeUserPath = "$env:APPDATA\Code\User"

# 1. Interactive Safety Prompt
$Confirmation = Read-Host "This script will link system configs to $Path and install extensions. Continue? (y/N)"
if ($Confirmation -notmatch '^[Yy]$') {
    Write-Host "Operation cancelled by user." -ForegroundColor Yellow
    exit
}

# 2. Backup Helper Function
$TimeStamp = Get-Date -Format "dd.MM.yyyy_HH.mm.ss"
$BackupDir = "$HOME\dotfiles_backup_$TimeStamp"

function New-SymlinkWithBackup {
    param (
        [string]$LinkPath,
        [string]$TargetPath
    )

    if (-not (Test-Path $TargetPath)) {
        Write-Host "Source target missing: $TargetPath" -ForegroundColor Red
        return
    }

    if (Test-Path $LinkPath) {
        $Item = Get-Item $LinkPath
        if (-not $Item.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint)) {
            if (-not (Test-Path $BackupDir)) {
                New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
                Write-Host "Created backup directory: $BackupDir" -ForegroundColor Cyan
            }
            Move-Item -Path $LinkPath -Destination "$BackupDir\" -Force
            Write-Host "Backed up existing $(Split-Path $LinkPath -Leaf)" -ForegroundColor Yellow
        }
    }

    New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -Force | Out-Null
    Write-Host "Symlink created: $LinkPath" -ForegroundColor Green
}

# 3. Create VS Code Symlinks
if (Test-Path $VSCodeUserPath) {
    Write-Host "`nSetting up VS Code configurations..." -ForegroundColor Cyan
    New-SymlinkWithBackup -LinkPath "$VSCodeUserPath\settings.json" -TargetPath "$Path\vscode\settings.json"
    New-SymlinkWithBackup -LinkPath "$VSCodeUserPath\keybindings.json" -TargetPath "$Path\vscode\keybindings.json"
    New-SymlinkWithBackup -LinkPath "$VSCodeUserPath\snippets" -TargetPath "$Path\vscode\snippets"
}

# 4. Create Git Symlinks
Write-Host "`nSetting up Git configurations..." -ForegroundColor Cyan
New-SymlinkWithBackup -LinkPath "$HOME\.gitconfig" -TargetPath "$Path\git\.gitconfig"
New-SymlinkWithBackup -LinkPath "$HOME\.gitignore_global" -TargetPath "$Path\git\.gitignore_global"

# 5. Create Bash Symlinks
Write-Host "`nSetting up Bash configurations..." -ForegroundColor Cyan
$BashFiles = @(".bashrc", ".bash_profile", ".bash_aliases", ".bash_logout")
foreach ($File in $BashFiles) {
    New-SymlinkWithBackup -LinkPath "$HOME\$File" -TargetPath "$Path\bash\$File"
}

# 6. Install VS Code Extensions
$ExtensionsFile = "$Path\vscode\extensions.txt"
if (Test-Path $ExtensionsFile) {
    Write-Host "`nInstalling VS Code Extensions..." -ForegroundColor Cyan
    Get-Content $ExtensionsFile | ForEach-Object {
        $Extension = $_.Trim()
        if ($Extension -and -not $Extension.StartsWith("#")) {
            code --install-extension $Extension --force
        }
    }
}

Write-Host "`nDotfiles installation completed successfully." -ForegroundColor Green
