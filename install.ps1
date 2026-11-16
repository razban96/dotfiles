#Requires -Version 7.0
#Requires -RunAsAdministrator

$DotfilesPath   = "C:\dotfiles"
$VSCodeUserPath = "$env:APPDATA\Code\User"
$WTSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# 1. Interactive Safety Prompt
$Confirmation = Read-Host "This script will link system configs to $DotfilesPath and install VS Code extensions. Continue? (y/N)"
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
        Write-Host "[SKIP] Source target missing: $TargetPath" -ForegroundColor DarkGray
        return
    }

    $ParentDir = Split-Path $LinkPath -Parent
    if (-not (Test-Path $ParentDir)) {
        New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
    }

    if (Test-Path $LinkPath) {
        $Item = Get-Item $LinkPath -Force
        if ($Item.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint) -and $Item.Target -eq $TargetPath) {
            Write-Host "[OK] Already linked: $LinkPath" -ForegroundColor DarkGray
            return
        }

        if (-not (Test-Path $BackupDir)) {
            New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
            Write-Host "Created backup directory: $BackupDir" -ForegroundColor Cyan
        }
        Move-Item -Path $LinkPath -Destination "$BackupDir\" -Force
        Write-Host "[BACKUP] Moved existing $(Split-Path $LinkPath -Leaf)" -ForegroundColor Yellow
    }

    New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -Force | Out-Null
    Write-Host "[LINKED] $LinkPath -> $TargetPath" -ForegroundColor Green
}

# 3. Common Cross-Platform Symlinks (Git, Bash, Code Formatting)
Write-Host "`nSetting up Common configurations..." -ForegroundColor Cyan
New-SymlinkWithBackup -LinkPath "$HOME\.gitconfig"        -TargetPath "$DotfilesPath\common\git\.gitconfig"
New-SymlinkWithBackup -LinkPath "$HOME\.gitignore_global" -TargetPath "$DotfilesPath\common\git\.gitignore_global"
New-SymlinkWithBackup -LinkPath "$HOME\.clang-format"     -TargetPath "$DotfilesPath\common\code\.clang-format"

$BashFiles = @(".bashrc", ".bash_profile", ".bash_aliases", ".bash_logout", ".minttyrc")
foreach ($File in $BashFiles) {
    New-SymlinkWithBackup -LinkPath "$HOME\$File" -TargetPath "$DotfilesPath\common\bash\$File"
}

# 4. VS Code Symlinks & Extensions
if (Test-Path $VSCodeUserPath) {
    Write-Host "`nSetting up VS Code configurations..." -ForegroundColor Cyan
    New-SymlinkWithBackup -LinkPath "$VSCodeUserPath\settings.json"    -TargetPath "$DotfilesPath\common\vscode\settings.json"
    New-SymlinkWithBackup -LinkPath "$VSCodeUserPath\keybindings.json" -TargetPath "$DotfilesPath\common\vscode\keybindings.json"
    New-SymlinkWithBackup -LinkPath "$VSCodeUserPath\snippets"         -TargetPath "$DotfilesPath\common\vscode\snippets"

    $ExtensionsFile = "$DotfilesPath\common\vscode\extensions.txt"
    if ((Test-Path $ExtensionsFile) -and (Get-Command code -ErrorAction SilentlyContinue)) {
        Write-Host "`nInstalling VS Code Extensions..." -ForegroundColor Cyan
        Get-Content $ExtensionsFile | ForEach-Object {
            $Extension = $_.Trim()
            if ($Extension -and -not $Extension.StartsWith("#")) {
                code --install-extension $Extension --force
            }
        }
    }
}

# 5. Windows-Specific Symlinks (PowerShell 7 & Windows Terminal)
Write-Host "`nSetting up Windows-specific configurations..." -ForegroundColor Cyan
New-SymlinkWithBackup -LinkPath $PROFILE.CurrentUserAllHosts -TargetPath "$DotfilesPath\windows\powershell\Microsoft.PowerShell_profile.ps1"
New-SymlinkWithBackup -LinkPath $WTSettingsPath              -TargetPath "$DotfilesPath\windows\terminal\settings.json"

Write-Host "`nDotfiles installation completed successfully." -ForegroundColor Green
