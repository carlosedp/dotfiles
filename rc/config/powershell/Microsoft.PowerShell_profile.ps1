# Powershell startup script

# Set Path
$env:PATH += ":/Users/cdepaula/go/bin/:/usr/local/bin/"

# Install required modules
$modules = @("VMware.PowerCLI", "PSFzf", "PSReadLine", "oh-my-posh", "posh-git", "git-aliases")
foreach ($module in $modules) {
    if (Get-Module -ListAvailable | Where-Object { $_.Name -eq $module }) {
        Write-Host "Module $module already installed."
    }
    else {
        Write-Host "Module $module does not exist, installing"
        Install-Module -Name $module -Scope "CurrentUser" -Confirm:$False -Force
    }
}

# replace 'Ctrl+t' and 'Ctrl+r' with your preferred bindings:
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# Replace tab completion
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

# Accept self-signed certificates
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Set timeout to 5 seconds
Set-PowerCLIConfiguration -WebOperationTimeoutSeconds 5 -Confirm:$false

# Connect to VCenter
# Define the variables VI_SERVER, VI_USERNAME and VI_PASSWORD in your environment
Connect-VIServer -Server $Env:VI_SERVER -User $Env:VI_USERNAME -Password $Env:VI_PASSWORD

# Load all modules from dir $Env:HOME/.dotfiles/powershell/*
[string]$items = Get-ChildItem -Path $Env:HOME/.dotfiles/powershell
$itemlist = $items.split(" ")
foreach ($item in $itemlist) {
    . $item
}

# Import git aliases
Import-Module git-aliases -DisableNameChecking

# Load custom prompt
Set-Theme Powerlevel10k-Classic

# Disable console title to fix iTerm2 alerts
if($env:LC_TERMINAL -eq "iTerm2") {
    $ThemeSettings.Options.ConsoleTitle = $false
}