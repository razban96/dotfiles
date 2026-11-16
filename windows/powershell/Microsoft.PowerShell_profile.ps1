# PowerShell 7 Profile

# 1. PSReadLine Predictive IntelliSense & Navigation
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine

    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -BellStyle None

    # Keybindings: Up/Down searches history matching current prefix; Ctrl+Right accepts next word
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}

# 2. Quick Navigation & Workflow Helpers
function dev { Set-Location "D:\dev\projects" }
function dots { Set-Location "C:\dotfiles" }
function gss { git status -s }
function glg { git log --oneline --graph --decorate -n 15 }

# 3. Initialize Starship Prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
