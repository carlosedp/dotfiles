
Function PoweronOCP {
    Get-VM -Location (Get-Folder -Name ocp*) | Where-Object { $_.Name -notlike '*rhcos*' } | Where-Object { $_.PowerState -eq "PoweredOff" } | Start-VM
}

Function ShutdownOCP {
    Get-VM -Location (Get-Folder -Name ocp*) | Where-Object { $_.PowerState -eq "PoweredOn" } | Shutdown-VMGuest
}

function PoweroffHost () {
    Get-VMHost | ForEach-Object { Get-View $_.ID } | ForEach-Object { $_.ShutdownHost_Task($TRUE) }
}