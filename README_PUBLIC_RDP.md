# Expose Windows RDP publicly (port-forward + DDNS) and keep it running 24/7

This guide explains how to make your Windows machine reachable over the public Internet (without Tailscale) and harden availability so RDP stays up.

Important: exposing RDP directly to the Internet is risky. Strongly consider alternatives (RD Gateway, VPN, or Cloud-hosted VM). If you proceed, follow the security notes below.

Quick steps
- Run the setup script as Administrator to enable RDP, add firewall rule, set service recovery, disable sleep, and optionally install a watchdog scheduled task:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.
\scripts\setup_public_rdp.ps1 -PublicPort 3389 -CreateWatchdog
```

- Configure your router: forward TCP port 3389 (or chosen port) to this machine's LAN IP. Prefer DHCP reservation for the host.
- Configure Dynamic DNS (No-IP, DuckDNS, etc.) on your router or install the provider's Windows client so a hostname points to your changing public IP.

Router / Port-forwarding notes
- Login to your router's admin UI and add a port-forward rule: external TCP port -> internal IP (your PC) port (match the PublicPort used above).
- If your ISP uses CGNAT, port-forwarding won't work; you'll need a cloud VM or a tunneling service.

Security recommendations
- Use a very strong RDP user password and avoid Administrator user when possible.
- Restrict the firewall rule to only allow trusted public IP ranges by editing the rule's `RemoteAddress` property or create a more specific rule.
- Consider changing the external port to a non-standard port to reduce brute-force noise.
- Enable Network Level Authentication (NLA) and keep Windows updated.
- Use RD Gateway or a VPN for secure access whenever possible.

Keeping RDP up 24/7
- `scripts\rdp_watchdog.ps1` is installed by the setup script as a scheduled task `RDP-Watchdog` (runs every 5 minutes). It restarts `TermService` if RDP is not listening, and reboots if restart fails.
- The script sets service recovery for `TermService` to automatically restart on failure.
- Ensure machine has a reliable power source and UPS if needed; disable sleep/hibernate as shown by the script.

Manual actions you must do on your network/router
- Reserve a static LAN IP (DHCP reservation) for this machine.
- Add port-forward rule in router.
- Configure DDNS or point a domain to your public IP.

If something breaks
- You can remove the scheduled task with:

```powershell
Unregister-ScheduledTask -TaskName "RDP-Watchdog" -Confirm:$false
```

Files added
- [scripts/setup_public_rdp.ps1](scripts/setup_public_rdp.ps1)
- [scripts/rdp_watchdog.ps1](scripts/rdp_watchdog.ps1)
