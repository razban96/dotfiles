#Requires -Version 7.0

$ErrorActionPreference = "Stop"
$DotfilesPath   = "C:\dotfiles"
$WTSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

function Sync-FileToRepo {
    param (
        [string]$LivePath,
        [string]$RepoPath
    )

    if (-not (Test-Path $LivePath)) {
        Write-Host "  [SKIP] Live file missing: $LivePath" -ForegroundColor DarkGray
        return
    }

    $Item = Get-Item $LivePath -Force
    if ($Item.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint) -and $Item.Target -eq $RepoPath) {
        Write-Host "  [OK] Symlink active (already up-to-date in repo): $RepoPath" -ForegroundColor DarkGray
        return
    }

    $RepoDir = Split-Path $RepoPath -Parent
    if (-not (Test-Path $RepoDir)) {
        New-Item -ItemType Directory -Force -Path $RepoDir | Out-Null
    }
    Copy-Item -Path $LivePath -Destination $RepoPath -Force
    Write-Host "  [SYNCED] $LivePath -> $RepoPath" -ForegroundColor Yellow
}

$BackupModules = [ordered]@{
    "1" = @{
        Scope  = "Common"
        Name   = "git (.gitconfig, .gitignore_global)"
        Action = {
            Sync-FileToRepo "$HOME\.gitconfig"        "$DotfilesPath\common\git\.gitconfig"
            Sync-FileToRepo "$HOME\.gitignore_global" "$DotfilesPath\common\git\.gitignore_global"
        }
    }
    "2" = @{
        Scope  = "Common"
        Name   = "bash (.bashrc, .bash_profile, .minttyrc)"
        Action = {
            foreach ($File in @(".bashrc", ".bash_profile", ".minttyrc")) {
                Sync-FileToRepo "$HOME\$File" "$DotfilesPath\common\bash\$File"
            }
        }
    }
    "3" = @{
        Scope  = "Common"
        Name   = "code (.clang-format)"
        Action = {
            Sync-FileToRepo "$HOME\.clang-format" "$DotfilesPath\common\code\.clang-format"
        }
    }
    "4" = @{
        Scope  = "Common"
        Name   = "shell (.aliases)"
        Action = {
            Sync-FileToRepo "$HOME\.aliases" "$DotfilesPath\common\shell\.aliases"
        }
    }
    "5" = @{
        Scope  = "Common"
        Name   = "starship (starship.toml)"
        Action = {
            Sync-FileToRepo "$DotfilesPath\.config\starship.toml" "$DotfilesPath\common\starship\starship.toml"
        }
    }
    "6" = @{
        Scope  = "Windows"
        Name   = "powershell (Microsoft.PowerShell_profile.ps1)"
        Action = {
            Sync-FileToRepo $PROFILE.CurrentUserAllHosts "$DotfilesPath\windows\powershell\Microsoft.PowerShell_profile.ps1"
        }
    }
    "7" = @{
        Scope  = "Windows"
        Name   = "terminal (Windows Terminal settings.json)"
        Action = {
            Sync-FileToRepo $WTSettingsPath "$DotfilesPath\windows\terminal\settings.json"
        }
    }
    "8" = @{
        Scope  = "Windows"
        Name   = "manifests (Export WinGet packages list)"
        Action = {
            $ManifestFile = "$DotfilesPath\windows\manifests\winget-packages.json"
            if (Get-Command winget -ErrorAction SilentlyContinue) {
                winget export -o $ManifestFile --accept-source-agreements | Out-Null
                Write-Host "  [EXPORTED] WinGet manifest -> $ManifestFile" -ForegroundColor Green
            } else {
                Write-Host "  [SKIP] winget not found." -ForegroundColor Red
            }
        }
    }
}

function Invoke-BackupModule($Key) {
    $mod = $BackupModules[$Key]
    Write-Host "`n--> Backing up [$($mod.Scope)] $($mod.Name)..." -ForegroundColor Cyan
    & $mod.Action
}

function Invoke-BackupScope($ScopeName) {
    foreach ($key in $BackupModules.Keys) {
        if ($BackupModules[$key].Scope -eq $ScopeName) {
            Invoke-BackupModule $key
        }
    }
}

$Mode = Read-Host "`nDotfiles Backup: [A] Backup Everything, [S] Select Modules, [0] Exit"
switch ($Mode.ToUpper()) {
    "0" { exit 0 }
    "A" {
        Invoke-BackupScope "Common"
        Invoke-BackupScope "Windows"
    }
    "S" {
        while ($true) {
            Write-Host "`n=== Select Module to Backup ===" -ForegroundColor Cyan
            Write-Host "  [C] All Common modules"
            Write-Host "  [W] All Windows modules"
            foreach ($key in $BackupModules.Keys) {
                Write-Host "  [$key] [$($BackupModules[$key].Scope)] $($BackupModules[$key].Name)"
            }
            Write-Host "  [0] Exit"

            $Choice = (Read-Host "`nEnter choice").ToUpper()
            if ($Choice -eq "0") { break }
            elseif ($Choice -eq "C") { Invoke-BackupScope "Common" }
            elseif ($Choice -eq "W") { Invoke-BackupScope "Windows" }
            elseif ($BackupModules.Contains($Choice)) { Invoke-BackupModule $Choice }
            else { Write-Host "Invalid selection." -ForegroundColor Red }
        }
    }
    default { Write-Host "Invalid option. Exiting." -ForegroundColor Yellow; exit 0 }
}

Push-Location $DotfilesPath
Write-Host "`nGit status in ${DotfilesPath}:" -ForegroundColor Cyan
git status -s
Pop-Location
