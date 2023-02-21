data "azurerm_resource_group" "test" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "test" {
  name                = "${terraform.workspace}-VNET"
  address_space       = length(var.address_spaces) == 0 ? [var.address_space] : var.address_spaces
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name = "${terraform.workspace}-Subnet"
  #resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.3.2.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "${terraform.workspace}-publicIPForLB"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}
