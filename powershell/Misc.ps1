
Function GetOversubscription {
    Foreach ($esx in Get-VMHost) {
        $vCPU = Get-VM -Location $esx | Measure-Object -Property NumCpu -Sum |
        Select-Object -ExpandProperty Sum
        $esx | Select-Object Name, @{N = 'pCPU'; E = { $_.NumCpu } },
        @{N = 'vCPU'; E = { $vCPU } },
        @{N = 'Ratio'; E = { [math]::Round($vCPU / $_.NumCpu, 1) } }
    }
}