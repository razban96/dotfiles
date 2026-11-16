#Requires -Version 7.0
#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"
$ManifestFile = "C:\dotfiles\windows\manifests\winget-packages.json"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "WinGet is not installed or not in PATH."
    exit 1
}

if (-not (Test-Path $ManifestFile)) {
    Write-Error "Manifest not found at $ManifestFile. Run .\backup.ps1 first to generate it."
    exit 1
}

$Confirm = Read-Host "Import and install packages from $ManifestFile? (y/N)"
if ($Confirm -notmatch '^[Yy]$') {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit
}

Write-Host "Updating WinGet sources..." -ForegroundColor Cyan
winget source update

Write-Host "Installing packages from manifest..." -ForegroundColor Cyan
winget import -i $ManifestFile --ignore-unavailable --ignore-versions --accept-package-agreements --accept-source-agreements

Write-Host "Package setup complete." -ForegroundColor Green
