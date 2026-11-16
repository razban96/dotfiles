#Requires -Version 7.0
#Requires -RunAsAdministrator

$DotfilesPath   = $PSScriptRoot
$WTSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$TimeStamp      = Get-Date -Format "dd.MM.yyyy_HH.mm.ss"
$BackupDir      = "$HOME\dotfiles_backup_$TimeStamp"

function New-SymlinkWithBackup {
    param (
        [string]$LinkPath,
        [string]$TargetPath
    )

    if (-not (Test-Path $TargetPath)) {
        Write-Host "  [SKIP] Source missing: $TargetPath" -ForegroundColor DarkGray
        return
    }

    $ParentDir = Split-Path $LinkPath -Parent
    if (-not (Test-Path $ParentDir)) {
        New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
    }

    if (Test-Path $LinkPath) {
        $Item = Get-Item $LinkPath -Force
        if ($Item.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint) -and $Item.Target -eq $TargetPath) {
            Write-Host "  [OK] Already linked: $LinkPath" -ForegroundColor DarkGray
            return
        }

        if (-not (Test-Path $BackupDir)) {
            New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
            Write-Host "  Created backup directory: $BackupDir" -ForegroundColor Cyan
        }
        Move-Item -Path $LinkPath -Destination "$BackupDir\" -Force
        Write-Host "  [BACKUP] Moved existing $(Split-Path $LinkPath -Leaf)" -ForegroundColor Yellow
    }

    New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -Force | Out-Null
    Write-Host "  [LINKED] $LinkPath -> $TargetPath" -ForegroundColor Green
}

$Modules = [ordered]@{
    "1" = @{
        Scope  = "Common"
        Name   = "git (.gitconfig, .gitignore_global)"
        Action = {
            New-SymlinkWithBackup "$HOME\.gitconfig"        "$DotfilesPath\common\git\.gitconfig"
            New-SymlinkWithBackup "$HOME\.gitignore_global" "$DotfilesPath\common\git\.gitignore_global"
        }
    }
    "2" = @{
        Scope  = "Common"
        Name   = "bash (.bashrc, .bash_profile)"
        Action = {
            foreach ($File in @(".bashrc", ".bash_profile")) {
                New-SymlinkWithBackup "$HOME\$File" "$DotfilesPath\common\bash\$File"
            }
        }
    }
    "3" = @{
        Scope  = "Common"
        Name   = "code (.clang-format)"
        Action = {
            New-SymlinkWithBackup "$HOME\.clang-format" "$DotfilesPath\common\code\.clang-format"
        }
    }
    "4" = @{
        Scope  = "Common"
        Name   = "shell (.aliases)"
        Action = {
            New-SymlinkWithBackup "$HOME\.aliases" "$DotfilesPath\common\shell\.aliases"
        }
    }
    "5" = @{
        Scope  = "Common"
        Name   = "starship (starship.toml)"
        Action = {
            New-SymlinkWithBackup "$HOME\.config\starship.toml" "$DotfilesPath\common\starship\starship.toml"
        }
    }
    "6" = @{
        Scope  = "Windows"
        Name   = "git-local (.gitconfig.local + .minttyrc)"
        Action = {
            New-SymlinkWithBackup "$HOME\.gitconfig.local" "$DotfilesPath\windows\git\.gitconfig.local"
            New-SymlinkWithBackup "$HOME\.minttyrc"        "$DotfilesPath\windows\bash\.minttyrc"
        }
    }
    "7" = @{
        Scope  = "Windows"
        Name   = "powershell (Microsoft.PowerShell_profile.ps1)"
        Action = {
            New-SymlinkWithBackup $PROFILE.CurrentUserCurrentHost "$DotfilesPath\windows\powershell\Microsoft.PowerShell_profile.ps1"
        }
    }
    "8" = @{
        Scope  = "Windows"
        Name   = "terminal (Windows Terminal settings.json)"
        Action = {
            New-SymlinkWithBackup $WTSettingsPath "$DotfilesPath\windows\terminal\settings.json"
        }
    }
}

function Invoke-InstallModule($Key) {
    $mod = $Modules[$Key]
    Write-Host "`n--> Installing [$($mod.Scope)] $($mod.Name)..." -ForegroundColor Cyan
    & $mod.Action
}

function Invoke-InstallScope($ScopeName) {
    foreach ($key in $Modules.Keys) {
        if ($Modules[$key].Scope -eq $ScopeName) {
            Invoke-InstallModule $key
        }
    }
}

$Mode = Read-Host "`nDotfiles Install: [A] Install Everything, [S] Select Modules, [0] Exit"
switch ($Mode.ToUpper()) {
    "0" { exit 0 }
    "A" {
        Invoke-InstallScope "Common"
        Invoke-InstallScope "Windows"
        Write-Host "`nAll modules installed." -ForegroundColor Green
        exit 0
    }
    "S" {
        while ($true) {
            Write-Host "`n=== Select Module to Install ===" -ForegroundColor Cyan
            Write-Host "  [C] All Common modules"
            Write-Host "  [W] All Windows modules"
            foreach ($key in $Modules.Keys) {
                Write-Host "  [$key] [$($Modules[$key].Scope)] $($Modules[$key].Name)"
            }
            Write-Host "  [0] Exit"

            $Choice = (Read-Host "`nEnter choice").ToUpper()
            if ($Choice -eq "0") { break }
            elseif ($Choice -eq "C") { Invoke-InstallScope "Common" }
            elseif ($Choice -eq "W") { Invoke-InstallScope "Windows" }
            elseif ($Modules.Contains($Choice)) { Invoke-InstallModule $Choice }
            else { Write-Host "Invalid selection." -ForegroundColor Red }
        }
    }
    default { Write-Host "Invalid option. Exiting." -ForegroundColor Yellow }
}
