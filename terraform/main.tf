variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "canadacentral"
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-tf-${var.environment}"
  location            = var.location
  resource_group_name = "rg-lab"
  address_space       = ["10.20.0.0/16"]

  tags = {
    environment = var.environment
    managedBy   = "terraform"
  }
}

resource "azurerm_subnet" "workload" {
  name                 = "snet-workload"
  resource_group_name  = "rg-lab"
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.20.1.0/24"]
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}
