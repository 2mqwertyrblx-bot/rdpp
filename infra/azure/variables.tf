variable "resource_group_name" {
  type    = string
  default = "rdp-rg"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vm_name" {
  type    = string
  default = "rdp-vm"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "admin_username" {
  type    = string
  default = "rdpadmin"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "rdp_port" {
  type    = number
  default = 3389
}

variable "allowed_source_cidr" {
  type    = string
  default = "0.0.0.0/0"
  description = "CIDR range allowed to connect to RDP. Set to your IP or small range for security."
}
