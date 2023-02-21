resource "azurerm_resource_group" "test" {
  name     = var.project_name
  location = var.app_location
}



resource "azurerm_virtual_network" "test" {
  name                = "${terraform.workspace}-VNET"
  address_space       = length(var.address_spaces) == 0 ? [var.address_space] : var.address_spaces
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "${terraform.workspace}-Subnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.3.2.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "${terraform.workspace}-publicIPForLB"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}
resource "azurerm_lb" "test" {
  name                = "${terraform.workspace}-loadBalancer"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = "${terraform.workspace}-publicIPAddress"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_backend_address_pool" "test" {
  loadbalancer_id = azurerm_lb.test.id
  name            = "${terraform.workspace}-BackEndAddressPool"
}

resource "azurerm_network_interface" "test" {
  count               = 2
  name                = "${terraform.workspace}-${var.vm_names[count.index]}-NIC"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testConfiguration"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_security_group" "test_NSG" {
  name                = "${terraform.workspace}-SecurityGroup"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "test"
  }
}

resource "azurerm_network_interface_security_group_association" "test_asso_nic" {
  count                     = "2"
  network_interface_id      = azurerm_network_interface.test[count.index].id
  network_security_group_id = azurerm_network_security_group.test_NSG.id
}

resource "azurerm_linux_virtual_machine" "test" {
  count                           = 2
  name                            = "${terraform.workspace}-${var.vm_names[count.index]}"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  network_interface_ids           = [element(azurerm_network_interface.test.*.id, count.index)]
  size                            = var.vm_size
  admin_username                  = "azureadmin"
  admin_password                  = "Hyper10n!"
  disable_password_authentication = "false"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true
  tags = {
    Name = "Sprint - ${terraform.workspace}"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"

  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}


data "azurerm_virtual_network" "transit_vnet" {
  resource_group_name = "ecisnerosRG"
  name                = "ecisnerosRG-vnet"
}



#*************************** VNet Peering ****************************

resource "azurerm_virtual_network_peering" "example-1" {
  name                      = "peer1to2"
  resource_group_name       = azurerm_resource_group.test.name
  virtual_network_name      = azurerm_virtual_network.test.name
  remote_virtual_network_id = data.azurerm_virtual_network.transit_vnet.id
}

resource "azurerm_virtual_network_peering" "example-2" {
  name                      = "peer2to1"
  resource_group_name       = "ecisnerosRG"
  virtual_network_name      = data.azurerm_virtual_network.transit_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.test.id
}
#*************************************************************



