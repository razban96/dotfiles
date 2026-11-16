#Requires -Version 7.0

$ErrorActionPreference = "Stop"
$DotfilesPath   = "C:\dotfiles"
$WTSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

Write-Host "Syncing Windows state into $DotfilesPath..." -ForegroundColor Cyan

# 1. Export installed WinGet packages to manifest
$ManifestFile = "$DotfilesPath\windows\manifests\winget-packages.json"
if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget export -o $ManifestFile --accept-source-agreements | Out-Null
    Write-Host "[EXPORTED] WinGet packages -> $ManifestFile" -ForegroundColor Green
}

# 2. Repair any broken symlinks by syncing unlinked files back to repo
$SyncMap = @{
    "$HOME\.gitconfig"        = "$DotfilesPath\common\git\.gitconfig"
    "$HOME\.gitignore_global" = "$DotfilesPath\common\git\.gitignore_global"
    "$HOME\.clang-format"     = "$DotfilesPath\common\code\.clang-format"
    "$HOME\.aliases"          = "$DotfilesPath\common\shell\.aliases"
    "$HOME\.bashrc"           = "$DotfilesPath\common\bash\.bashrc"
    "$HOME\.bash_profile"     = "$DotfilesPath\common\bash\.bash_profile"
    "$HOME\.minttyrc"         = "$DotfilesPath\common\bash\.minttyrc"
    "$DotfilesPath\.config\starship.toml" = "$DotfilesPath\common\starship\starship.toml"
    $PROFILE.CurrentUserAllHosts          = "$DotfilesPath\windows\powershell\Microsoft.PowerShell_profile.ps1"
    $WTSettingsPath                       = "$DotfilesPath\windows\terminal\settings.json"
}

foreach ($entry in $SyncMap.GetEnumerator()) {
    if (Test-Path $entry.Key) {
        $item = Get-Item $entry.Key -Force
        if ($item.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint) -and $item.Target -eq $entry.Value) {
            continue
        }
        Copy-Item -Path $entry.Key -Destination $entry.Value -Force
        Write-Host "[SYNCED] $($entry.Key) -> $($entry.Value)" -ForegroundColor Yellow
    }
}

Push-Location $DotfilesPath
git status -s
Pop-Location
