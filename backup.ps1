#Requires -Version 7.0

$ErrorActionPreference = "Stop"
$DotfilesPath   = "C:\dotfiles"
$VSCodeUserPath = "$env:APPDATA\Code\User"
$WTSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

Write-Host "Syncing current Windows state into $DotfilesPath..." -ForegroundColor Cyan

# 1. Export current VS Code extensions list
$ExtensionsFile = "$DotfilesPath\common\vscode\extensions.txt"
if (Get-Command code -ErrorAction SilentlyContinue) {
    code --list-extensions | Sort-Object | Set-Content -Path $ExtensionsFile -Encoding UTF8
    Write-Host "[EXPORTED] VS Code extensions -> $ExtensionsFile" -ForegroundColor Green
}

# 2. Sync any non-symlinked local files back into C:\dotfiles (fallback if a link was broken)
$SyncMap = @{
    "$HOME\.gitconfig"                 = "$DotfilesPath\common\git\.gitconfig"
    "$HOME\.gitignore_global"          = "$DotfilesPath\common\git\.gitignore_global"
    "$HOME\.clang-format"              = "$DotfilesPath\common\code\.clang-format"
    "$HOME\.bashrc"                    = "$DotfilesPath\common\bash\.bashrc"
    "$HOME\.bash_profile"              = "$DotfilesPath\common\bash\.bash_profile"
    "$HOME\.minttyrc"                  = "$DotfilesPath\common\bash\.minttyrc"
    "$VSCodeUserPath\settings.json"    = "$DotfilesPath\common\vscode\settings.json"
    "$VSCodeUserPath\keybindings.json" = "$DotfilesPath\common\vscode\keybindings.json"
    $PROFILE.CurrentUserAllHosts       = "$DotfilesPath\windows\powershell\Microsoft.PowerShell_profile.ps1"
    $WTSettingsPath                    = "$DotfilesPath\windows\terminal\settings.json"
}

foreach ($entry in $SyncMap.GetEnumerator()) {
    $livePath = $entry.Key
    $repoPath = $entry.Value

    if (Test-Path $livePath) {
        $item = Get-Item $livePath -Force
        if ($item.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint) -and $item.Target -eq $repoPath) {
            continue
        }

        $repoDir = Split-Path $repoPath -Parent
        if (-not (Test-Path $repoDir)) {
            New-Item -ItemType Directory -Force -Path $repoDir | Out-Null
        }
        Copy-Item -Path $livePath -Destination $repoPath -Force
        Write-Host "[SYNCED] $livePath -> $repoPath" -ForegroundColor Yellow
    }
}

# 3. Show Git status summary
Push-Location $DotfilesPath
Write-Host "`nCurrent Git status in ${DotfilesPath}:" -ForegroundColor Cyan
git status -s
Pop-Location
