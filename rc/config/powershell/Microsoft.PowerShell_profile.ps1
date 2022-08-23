# Powershell startup script

# Install required modules
Function InstallModules {
    $modules = @("VMware.PowerCLI", "PSFzf", "PSReadLine", "posh-git", "git-aliases", "TabExpansionPlusPlus")
    foreach ($module in $modules) {
        if (Get-Module -ListAvailable | Where-Object { $_.Name -eq $module }) {
            Write-Host "Module $module already installed, updating..."
            Update-Module -Name $module -Scope "CurrentUser" -Confirm:$False -Force
        }
        else {
            Write-Host "Module $module does not exist, installing"
            Install-Module -Name $module -Scope "CurrentUser" -Confirm:$False -Force
        }
    }
}

# Set Path
$env:PATH += ":$Env:HOME/go/bin/:/usr/local/bin/"

# Load all modules from dir $Env:HOME/.dotfiles/powershell/*
[string]$items = Get-ChildItem -Path $Env:HOME/.dotfiles/powershell
$itemlist = $items.split(" ")
foreach ($item in $itemlist) {
    . $item
}

# replace 'Ctrl+t' and 'Ctrl+r' with your preferred bindings:
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# Enable autocompletion
Set-PSReadLineOption -PredictionSource History

# Replace tab completion
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

# Import modules
Import-Module git-aliases -DisableNameChecking
Import-Module TabExpansionPlusPlus

# Load custom prompt
oh-my-posh init pwsh --config "$(brew --prefix oh-my-posh)\themes\powerlevel10k_classic.omp.json" | Invoke-Expression

# Disable console title to fix iTerm2 alerts
# if($env:LC_TERMINAL -eq "iTerm2") {
#     $ThemeSettings.Options.ConsoleTitle = $false
# }

ConnectVCenter