param([int]$Port = 3389)

if(-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    Write-Error "This watchdog must be run as Administrator."; exit 1
}

Write-Host "Checking RDP port $Port on localhost..."
$ok = Test-NetConnection -ComputerName 127.0.0.1 -Port $Port -InformationLevel Quiet
if(-not $ok){
    Write-Host "RDP port $Port is closed. Restarting TermService..."
    try{ Restart-Service TermService -Force -ErrorAction Stop } catch { Write-Warning "Failed to restart TermService: $_" }
    Start-Sleep -Seconds 15
    $ok2 = Test-NetConnection -ComputerName 127.0.0.1 -Port $Port -InformationLevel Quiet
    if(-not $ok2){
        Write-Host "Still not reachable. Rebooting machine to recover..."
        Restart-Computer -Force
    }
} else {
    Write-Host "RDP port $Port is open. All good." 
}
