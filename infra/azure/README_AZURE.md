# Azure provisioning (Terraform)

This folder contains Terraform configuration to create a Windows VM with a public static IP and an NSG rule permitting RDP.

Prerequisites
- Install Terraform (>= 1.0)
- Install and authenticate Azure CLI: `az login` and `az account set --subscription <id>`

Quick deploy
1. Initialize Terraform

```bash
cd infra/azure
terraform init
```

2. Create a `terraform.tfvars` file with an admin password (do not commit):

```hcl
admin_password = "YourStrongPasswordHere!"
location = "eastus"
allowed_source_cidr = "0.0.0.0/0" # replace with your client IP/CIDR for security
```

3. Apply

```bash
terraform apply
```

After apply completes, Terraform outputs include the public IP. Use Remote Desktop to connect to `public_ip:rdp_port` with the admin username `rdpadmin` (or value in variables).

Post-deploy (recommended)
- RDP in and run the repository's `scripts\setup_public_rdp.ps1` as Administrator to install the watchdog and harden the VM:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
cd C:\path\to\repo
.\scripts\setup_public_rdp.ps1 -PublicPort 3389 -CreateWatchdog
```

- Restrict the NSG `allowed_source_cidr` to your home/work IP instead of `0.0.0.0/0`.
- Consider enabling automatic updates and monitoring.

If you want, I can generate a Terraform `-auto.tfvars` template and an Azure Custom Script Extension to run the `setup_public_rdp.ps1` automatically after VM creation — tell me if you want that automated.
