#Requires -Version 7.0
#Requires -RunAsAdministrator

$DotfilesPath   = "C:\dotfiles"
$WTSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

$Confirmation = Read-Host "Link Windows & Common configs to $DotfilesPath? (y/N)"
if ($Confirmation -notmatch '^[Yy]$') {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit
}

$TimeStamp = Get-Date -Format "dd.MM.yyyy_HH.mm.ss"
$BackupDir = "$HOME\dotfiles_backup_$TimeStamp"

function New-SymlinkWithBackup {
    param (
        [string]$LinkPath,
        [string]$TargetPath
    )

    if (-not (Test-Path $TargetPath)) {
        Write-Host "[SKIP] Source missing: $TargetPath" -ForegroundColor DarkGray
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

Write-Host "`nSetting up Common configurations..." -ForegroundColor Cyan
New-SymlinkWithBackup -LinkPath "$HOME\.gitconfig"        -TargetPath "$DotfilesPath\common\git\.gitconfig"
New-SymlinkWithBackup -LinkPath "$HOME\.gitignore_global" -TargetPath "$DotfilesPath\common\git\.gitignore_global"
New-SymlinkWithBackup -LinkPath "$HOME\.clang-format"     -TargetPath "$DotfilesPath\common\code\.clang-format"
New-SymlinkWithBackup -LinkPath "$HOME\.aliases"          -TargetPath "$DotfilesPath\common\shell\.aliases"
New-SymlinkWithBackup -LinkPath "$DotfilesPath\.config\starship.toml" -TargetPath "$DotfilesPath\common\starship\starship.toml"

foreach ($File in @(".bashrc", ".bash_profile", ".minttyrc")) {
    New-SymlinkWithBackup -LinkPath "$HOME\$File" -TargetPath "$DotfilesPath\common\bash\$File"
}

Write-Host "`nSetting up Windows-specific configurations..." -ForegroundColor Cyan
New-SymlinkWithBackup -LinkPath $PROFILE.CurrentUserAllHosts -TargetPath "$DotfilesPath\windows\powershell\Microsoft.PowerShell_profile.ps1"
New-SymlinkWithBackup -LinkPath $WTSettingsPath              -TargetPath "$DotfilesPath\windows\terminal\settings.json"

Write-Host "`nDotfiles installation completed successfully." -ForegroundColor Green
