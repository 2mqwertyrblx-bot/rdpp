resource "azurerm_virtual_machine_extension" "custom_script" {
  name                       = "setup-public-rdp"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"

  settings = <<SETTINGS
{
  "fileUris": ["${var.setup_script_url}"],
  "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File setup_public_rdp.ps1 -PublicPort ${var.rdp_port} -CreateWatchdog"
}
SETTINGS

  protected_settings = <<PROTECTED
{}
PROTECTED
}
