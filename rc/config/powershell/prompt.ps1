function global:prompt {
    $Success = $?
 
    ## Time calculation
    $LastExecutionTimeSpan = if (@(Get-History).Count -gt 0) {
        Get-History | Select-Object -Last 1 | ForEach-Object {
            New-TimeSpan -Start $_.StartExecutionTime -End $_.EndExecutionTime
        }
    }
    else {
        New-TimeSpan
    }
 
    $LastExecutionShortTime = if ($LastExecutionTimeSpan.Days -gt 0) {
        "$($LastExecutionTimeSpan.Days + [Math]::Round($LastExecutionTimeSpan.Hours / 24, 2)) d"
    }
    elseif ($LastExecutionTimeSpan.Hours -gt 0) {
        "$($LastExecutionTimeSpan.Hours + [Math]::Round($LastExecutionTimeSpan.Minutes / 60, 2)) h"
    }
    elseif ($LastExecutionTimeSpan.Minutes -gt 0) {
        "$($LastExecutionTimeSpan.Minutes + [Math]::Round($LastExecutionTimeSpan.Seconds / 60, 2)) m"
    }
    elseif ($LastExecutionTimeSpan.Seconds -gt 0) {
        "$($LastExecutionTimeSpan.Seconds + [Math]::Round($LastExecutionTimeSpan.Milliseconds / 1000, 2)) s"
    }
    elseif ($LastExecutionTimeSpan.Milliseconds -gt 0) {
        "$([Math]::Round($LastExecutionTimeSpan.TotalMilliseconds, 2)) ms"
    }
    else {
        "0 s"
    }
 
    if ($Success) {
        Write-Host -Object "[$LastExecutionShortTime] " -NoNewline -ForegroundColor Green
    }
    else {
        Write-Host -Object "! [$LastExecutionShortTime] " -NoNewline -ForegroundColor Red
    }
 
    ## History ID
    $HistoryId = $MyInvocation.HistoryId
    Write-Host -Object "$HistoryId`: " -NoNewline -ForegroundColor Cyan
 
    ## Path
    $PwdPath = Split-Path -Path $pwd -Leaf
    Write-Host -Object "$PwdPath" -NoNewline -ForegroundColor Magenta
 
    return "> "
}