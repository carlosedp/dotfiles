# Connect to VCenter
# Define the variables VI_SERVER, VI_USERNAME and VI_PASSWORD in your environment
Function ConnectVCenter {
    # Accept self-signed certificates
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

    # Set timeout to 2 seconds
    Set-PowerCLIConfiguration -WebOperationTimeoutSeconds 2 -Confirm:$false
    Connect-VIServer -Server $Env:VI_SERVER -User $Env:VI_USERNAME -Password $Env:VI_PASSWORD
}

Function GetOversubscription {
    Foreach ($esx in Get-VMHost) {
        $vCPU = Get-VM -Location $esx | Measure-Object -Property NumCpu -Sum |
        Select-Object -ExpandProperty Sum
        $esx | Select-Object Name, @{N = 'pCPU'; E = { $_.NumCpu } },
        @{N = 'vCPU'; E = { $vCPU } },
        @{N = 'Ratio'; E = { [math]::Round($vCPU / $_.NumCpu, 1) } }
    }
}