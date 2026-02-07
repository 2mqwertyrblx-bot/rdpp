param(
    [int]$PublicPort = 3389,
    [switch]$ChangeRdpPort,
    [int]$NewRdpPort = 3389,
    [switch]$CreateWatchdog
)

if(-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    Write-Error "This script must be run as Administrator."; exit 1
}

Write-Host "Enabling Remote Desktop..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

Write-Host "Adding firewall rule for TCP port $PublicPort..."
if(-not (Get-NetFirewallRule -DisplayName "RDP Public" -ErrorAction SilentlyContinue)){
    New-NetFirewallRule -DisplayName "RDP Public" -Direction Inbound -Protocol TCP -LocalPort $PublicPort -Action Allow
} else {
    Set-NetFirewallRule -DisplayName "RDP Public" -Enabled True
}

if($ChangeRdpPort){
    $portKey = "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
    Write-Host "Changing RDP port to $NewRdpPort in registry..."
    Set-ItemProperty -Path $portKey -Name "PortNumber" -Value $NewRdpPort
    Write-Host "Adjusted registry. Firewall rule was created on port $PublicPort. Consider aligning ports." 
}

Write-Host "Configuring service recovery for Remote Desktop Service (TermService)..."
sc.exe failure TermService reset= 86400 actions= restart/60000/restart/60000

Write-Host "Disabling sleep/hibernate for AC power..."
powercfg -change -standby-timeout-ac 0
powercfg -change -hibernate-timeout-ac 0
powercfg -change -monitor-timeout-ac 0

if($CreateWatchdog){
    $scriptPath = Join-Path $PSScriptRoot 'rdp_watchdog.ps1'
    if(-not (Test-Path $scriptPath)){
        Write-Warning "Watchdog script not found at $scriptPath. Create scripts/rdp_watchdog.ps1 first." 
    } else {
        Write-Host "Registering scheduled task 'RDP-Watchdog' to run every 5 minutes..."
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`" -Port $PublicPort"
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration ([TimeSpan]::MaxValue)
        Register-ScheduledTask -TaskName "RDP-Watchdog" -Action $action -Trigger $trigger -RunLevel Highest -Force
        Write-Host "Scheduled task created." 
    }
}

Write-Host "Restarting Remote Desktop Service to apply changes..."
Restart-Service TermService -Force

Write-Host "Setup finished. Next steps:"
Write-Host "- Configure your router: forward TCP $PublicPort -> this machine's LAN IP (set DHCP reservation if possible)."
Write-Host "- Configure DDNS (No-IP, DuckDNS, etc.) or point a domain A record to your public IP."
Write-Host "- Consider restricting inbound addresses in the firewall or using RD Gateway for security."
