# Powershell startup script

# Install required modules
$modules = @("VMware.PowerCLI")
foreach ($module in $modules) {
    if (Get-Module -ListAvailable | Where-Object { $_.Name -eq $module }) {
        Write-Host "Module $module already installed."
    }
    else {
        Write-Host "Module $module does not exist, installing"
        Install-Module -Name $module -Scope "CurrentUser"
    }
}

# Accept self-signed certificates
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Connect to VCenter
# Define the variables VI_SERVER, VI_USERNAME and VI_PASSWORD in your environment
Connect-VIServer -Server $Env:VI_SERVER -User $Env:VI_USERNAME -Password $Env:VI_PASSWORD

# Load all modules from dir $Env:HOME/.dotfiles/powershell/*
[string]$items = Get-ChildItem -Path $Env:HOME/.dotfiles/powershell
$itemlist = $items.split(" ")
foreach ($item in $itemlist) {
    . $item
}

# Load custom prompt
. $Env:HOME/.config/powershell/prompt.ps1