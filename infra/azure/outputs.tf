output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}

output "vm_name" {
  value = azurerm_windows_virtual_machine.vm.name
}

output "admin_username" {
  value = var.admin_username
}

output "rdp_port" {
  value = var.rdp_port
}
